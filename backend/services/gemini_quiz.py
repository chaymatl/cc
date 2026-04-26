"""
EcoRewind Gemini Quiz Service
==============================
Utilise l'API Google Gemini pour :
  1. Extraire les questions/réponses d'un PDF de quiz
  2. Corriger automatiquement les réponses des étudiants
  3. Attribuer une note sur 10 avec feedback détaillé
"""

import os
import json
import base64
import httpx
from typing import Optional

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = "gemini-2.5-flash"
GEMINI_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"


def _call_gemini(prompt: str, pdf_bytes: Optional[bytes] = None) -> dict:
    """Appel synchrone à l'API Gemini avec support PDF inline."""
    if not GEMINI_API_KEY:
        raise ValueError("GEMINI_API_KEY non configurée dans le .env")

    parts = []

    # Si un PDF est fourni, l'envoyer en inline (base64)
    if pdf_bytes:
        b64 = base64.standard_b64encode(pdf_bytes).decode("utf-8")
        parts.append({
            "inline_data": {
                "mime_type": "application/pdf",
                "data": b64,
            }
        })

    parts.append({"text": prompt})

    payload = {
        "contents": [{"parts": parts}],
        "generationConfig": {
            "temperature": 0.1,  # Réponses précises et déterministes
            "maxOutputTokens": 8192,
            "responseMimeType": "application/json",
        },
    }

    resp = httpx.post(
        GEMINI_URL,
        params={"key": GEMINI_API_KEY},
        json=payload,
        timeout=120.0,
    )

    if resp.status_code != 200:
        raise RuntimeError(f"Gemini API error {resp.status_code}: {resp.text[:500]}")

    data = resp.json()
    text = data["candidates"][0]["content"]["parts"][0]["text"]

    # Parser le JSON retourné par Gemini
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        # Tenter d'extraire le JSON d'un bloc markdown ```json ... ```
        import re
        match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
        if match:
            return json.loads(match.group(1))
        raise ValueError(f"Gemini n'a pas retourné du JSON valide: {text[:300]}")


def extract_quiz_from_pdf(pdf_bytes: bytes) -> dict:
    """
    Extrait les questions et réponses correctes d'un PDF de quiz.

    Retourne:
    {
        "title": "Quiz Tri des Déchets",
        "total_questions": 10,
        "questions": [
            {
                "number": 1,
                "question": "Quel bac pour le plastique ?",
                "type": "mcq",  # mcq | open | true_false
                "options": ["A. Jaune", "B. Vert", "C. Bleu", "D. Noir"],
                "correct_answer": "A",
                "explanation": "Le bac jaune est réservé aux emballages plastiques."
            },
            ...
        ]
    }
    """
    prompt = """Tu es un assistant éducatif spécialisé dans l'analyse de quiz PDF.

Analyse ce document PDF et extrait TOUTES les questions du quiz.

Pour chaque question, détermine :
- Le numéro de la question
- Le texte de la question
- Le type : "mcq" (QCM), "true_false" (Vrai/Faux), ou "open" (question ouverte)
- Les options de réponse (si QCM)
- La réponse correcte (la lettre pour QCM, "Vrai"/"Faux" pour V/F, ou la réponse attendue pour les questions ouvertes)
- Une explication courte de pourquoi c'est la bonne réponse

Retourne un JSON avec cette structure exacte :
{
    "title": "Titre du quiz détecté dans le PDF",
    "total_questions": <nombre>,
    "questions": [
        {
            "number": 1,
            "question": "texte de la question",
            "type": "mcq",
            "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
            "correct_answer": "A",
            "explanation": "Explication courte"
        }
    ]
}

IMPORTANT:
- Si les réponses correctes sont indiquées dans le PDF, utilise-les
- Si elles ne sont PAS indiquées, utilise tes connaissances pour déterminer la bonne réponse
- Chaque question doit avoir une réponse correcte
- Pour les questions ouvertes, donne la réponse attendue la plus complète possible"""

    return _call_gemini(prompt, pdf_bytes)


def grade_submission(questions: list, answers: dict) -> dict:
    """
    Corrige les réponses d'un étudiant en utilisant Gemini.

    Args:
        questions: Liste des questions avec réponses correctes
        answers: Dict {numéro_question: réponse_étudiant}

    Retourne:
    {
        "score": 7.5,
        "max_score": 10,
        "total_correct": 8,
        "total_questions": 10,
        "details": [
            {
                "number": 1,
                "student_answer": "B",
                "correct_answer": "A",
                "is_correct": false,
                "points": 0,
                "feedback": "La bonne réponse est A car..."
            }
        ],
        "general_feedback": "Bon travail ! Révisez le chapitre sur..."
    }
    """
    prompt = f"""Tu es un correcteur de quiz éducatif.

Voici les questions du quiz avec les réponses correctes :
{json.dumps(questions, ensure_ascii=False, indent=2)}

Voici les réponses de l'étudiant (numéro de question → réponse) :
{json.dumps(answers, ensure_ascii=False, indent=2)}

Corrige chaque réponse et attribue une note sur 10.

Règles de notation :
- Chaque question vaut le même nombre de points (10 / nombre_total_questions)
- Pour les QCM et Vrai/Faux : la réponse est correcte ou incorrecte (pas de demi-point)
- Pour les questions ouvertes : accorde des points partiels si la réponse est partiellement correcte
- Si l'étudiant n'a pas répondu à une question, c'est 0 point

Retourne un JSON avec cette structure exacte :
{{
    "score": <note sur 10, arrondie à 1 décimale>,
    "max_score": 10,
    "total_correct": <nombre de réponses correctes>,
    "total_questions": <nombre total de questions>,
    "details": [
        {{
            "number": 1,
            "student_answer": "réponse de l'étudiant",
            "correct_answer": "bonne réponse",
            "is_correct": true/false,
            "points": <points obtenus pour cette question>,
            "feedback": "Explication courte"
        }}
    ],
    "general_feedback": "Feedback général encourageant avec conseils de révision"
}}"""

    return _call_gemini(prompt)


def grade_pdf_submission(quiz_pdf_bytes: bytes, submission_pdf_bytes: bytes) -> dict:
    """
    Corrige directement un PDF de réponses d'étudiant en le comparant au quiz original.
    L'étudiant soumet un PDF avec ses réponses, et Gemini compare avec le quiz.

    Retourne le même format que grade_submission().
    """
    # Encoder les deux PDFs
    quiz_b64 = base64.standard_b64encode(quiz_pdf_bytes).decode("utf-8")
    submission_b64 = base64.standard_b64encode(submission_pdf_bytes).decode("utf-8")

    parts = [
        {
            "inline_data": {
                "mime_type": "application/pdf",
                "data": quiz_b64,
            }
        },
        {"text": "Ceci est le quiz original avec les questions."},
        {
            "inline_data": {
                "mime_type": "application/pdf",
                "data": submission_b64,
            }
        },
        {"text": """Ceci est la copie de l'étudiant avec ses réponses.

Compare les réponses de l'étudiant avec le quiz original.
Corrige chaque réponse et attribue une note sur 10.

Règles :
- Chaque question vaut le même nombre de points (10 / nombre_total)
- QCM/Vrai-Faux : correct ou incorrect (pas de demi-point)
- Questions ouvertes : points partiels possibles si partiellement correct
- Question sans réponse = 0 point

Retourne un JSON avec cette structure :
{
    "score": <note sur 10>,
    "max_score": 10,
    "total_correct": <nombre correctes>,
    "total_questions": <nombre total>,
    "details": [
        {
            "number": 1,
            "question": "texte de la question",
            "student_answer": "réponse étudiant",
            "correct_answer": "bonne réponse",
            "is_correct": true/false,
            "points": <points>,
            "feedback": "explication"
        }
    ],
    "general_feedback": "Feedback global encourageant"
}"""},
    ]

    payload = {
        "contents": [{"parts": parts}],
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 8192,
            "responseMimeType": "application/json",
        },
    }

    resp = httpx.post(
        GEMINI_URL,
        params={"key": GEMINI_API_KEY},
        json=payload,
        timeout=120.0,
    )

    if resp.status_code != 200:
        raise RuntimeError(f"Gemini API error {resp.status_code}: {resp.text[:500]}")

    data = resp.json()
    text = data["candidates"][0]["content"]["parts"][0]["text"]

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        import re
        match = re.search(r"```json\s*(.*?)\s*```", text, re.DOTALL)
        if match:
            return json.loads(match.group(1))
        raise ValueError(f"Gemini JSON parse error: {text[:300]}")
