"""
services/email_service.py
─────────────────────────
Service d'envoi d'emails via Gmail SMTP.

Configuration (.env) :
  SMTP_EMAIL     = votre.adresse@gmail.com
  SMTP_PASSWORD  = xxxx xxxx xxxx xxxx   ← Mot de passe d'application Gmail
                   (Compte Google → Sécurité → Mots de passe des applications)

Si SMTP_EMAIL n'est pas configuré → mode noop (pas d'erreur fatale).
"""

import os
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime
from typing import List


_SMTP_EMAIL    = os.getenv("SMTP_EMAIL", "")
_SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
_SMTP_HOST     = os.getenv("SMTP_HOST", "smtp.gmail.com")
_SMTP_PORT     = int(os.getenv("SMTP_PORT", "465"))


def _is_configured() -> bool:
    return bool(_SMTP_EMAIL and _SMTP_PASSWORD)


def send_meeting_invitation(
    to_emails: List[str],
    recipient_names: List[str],
    educator_name: str,
    course_title: str,
    description: str,
    scheduled_at: datetime,
    duration_minutes: int,
    meet_link: str,
    group_name: str = "",
) -> bool:
    """
    Envoie une invitation Google Meet par email à chaque citoyen.
    Retourne True si au moins un email a été envoyé avec succès.
    """
    if not _is_configured():
        print("[Email] SMTP non configuré — emails désactivés (mode noop)")
        return False

    date_str = scheduled_at.strftime("%A %d %B %Y à %H:%M")
    success_count = 0

    context = ssl.create_default_context()
    try:
        with smtplib.SMTP_SSL(_SMTP_HOST, _SMTP_PORT, context=context) as server:
            server.login(_SMTP_EMAIL, _SMTP_PASSWORD)

            for email, name in zip(to_emails, recipient_names):
                try:
                    msg = _build_invitation_email(
                        to_email=email,
                        recipient_name=name,
                        educator_name=educator_name,
                        course_title=course_title,
                        description=description,
                        date_str=date_str,
                        duration_minutes=duration_minutes,
                        meet_link=meet_link,
                        group_name=group_name,
                    )
                    server.sendmail(_SMTP_EMAIL, email, msg.as_string())
                    success_count += 1
                    print(f"[Email] ✅ Invitation envoyée à {email}")
                except Exception as e:
                    print(f"[Email] ❌ Échec envoi à {email} : {e}")

    except Exception as e:
        print(f"[Email] ❌ Connexion SMTP échouée : {e}")
        return False

    return success_count > 0


def _build_invitation_email(
    to_email: str,
    recipient_name: str,
    educator_name: str,
    course_title: str,
    description: str,
    date_str: str,
    duration_minutes: int,
    meet_link: str,
    group_name: str,
) -> MIMEMultipart:
    """Construit le message email HTML."""
    msg = MIMEMultipart("alternative")
    msg["Subject"] = f"📅 Invitation : {course_title} — EcoRewind"
    msg["From"]    = f"EcoRewind <{_SMTP_EMAIL}>"
    msg["To"]      = to_email

    group_line = f"<p>👥 <strong>Groupe :</strong> {group_name}</p>" if group_name else ""
    desc_section = f"""
        <div style="background:#f0faf5;border-left:4px solid #00C896;padding:12px 16px;border-radius:4px;margin:16px 0;">
            <p style="margin:0;color:#333;font-size:14px;">{description}</p>
        </div>
    """ if description else ""

    html = f"""
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
<body style="margin:0;padding:0;background:#f4f7f6;font-family:'Segoe UI',Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f7f6;padding:40px 20px;">
    <tr><td>
      <table width="600" cellpadding="0" cellspacing="0" align="center"
             style="background:#ffffff;border-radius:16px;overflow:hidden;
                    box-shadow:0 4px 24px rgba(0,0,0,0.08);max-width:600px;width:100%;">

        <!-- Header vert -->
        <tr>
          <td style="background:linear-gradient(135deg,#00C896,#00A878);padding:32px 40px;text-align:center;">
            <h1 style="color:#fff;margin:0;font-size:26px;font-weight:800;letter-spacing:-0.5px;">
              🌿 EcoRewind
            </h1>
            <p style="color:rgba(255,255,255,0.85);margin:8px 0 0;font-size:14px;">
              Plateforme éco-citoyenne
            </p>
          </td>
        </tr>

        <!-- Corps -->
        <tr>
          <td style="padding:36px 40px;">
            <p style="color:#555;font-size:15px;margin:0 0 8px;">Bonjour <strong>{recipient_name}</strong>,</p>
            <p style="color:#555;font-size:15px;margin:0 0 24px;">
              <strong>{educator_name}</strong> vous invite à participer à une séance en ligne :
            </p>

            <!-- Carte séance -->
            <div style="background:#f9fffe;border:1.5px solid #00C896;border-radius:12px;padding:24px;">
              <h2 style="color:#00C896;margin:0 0 16px;font-size:20px;">📚 {course_title}</h2>
              {desc_section}
              <table cellpadding="0" cellspacing="0" width="100%">
                <tr>
                  <td style="padding:6px 0;">
                    <span style="color:#888;font-size:13px;">📅 Date &amp; heure</span><br>
                    <strong style="color:#222;font-size:15px;">{date_str}</strong>
                  </td>
                </tr>
                <tr>
                  <td style="padding:6px 0;">
                    <span style="color:#888;font-size:13px;">⏱️ Durée</span><br>
                    <strong style="color:#222;font-size:15px;">{duration_minutes} minutes</strong>
                  </td>
                </tr>
                {group_line}
              </table>
            </div>

            <!-- Bouton Rejoindre -->
            <div style="text-align:center;margin:28px 0;">
              <a href="{meet_link}"
                 style="display:inline-block;background:#00C896;color:#fff;text-decoration:none;
                        font-weight:700;font-size:16px;padding:14px 36px;border-radius:50px;
                        letter-spacing:0.3px;">
                📹 Rejoindre Google Meet
              </a>
            </div>

            <p style="color:#aaa;font-size:12px;text-align:center;margin:0;">
              Lien direct : <a href="{meet_link}" style="color:#00C896;">{meet_link}</a>
            </p>
          </td>
        </tr>

        <!-- Footer -->
        <tr>
          <td style="background:#f4f7f6;padding:20px 40px;text-align:center;border-top:1px solid #eee;">
            <p style="color:#aaa;font-size:12px;margin:0;">
              Vous recevez cet email car vous êtes membre de la plateforme EcoRewind.<br>
              © 2026 EcoRewind — Tous droits réservés
            </p>
          </td>
        </tr>

      </table>
    </td></tr>
  </table>
</body>
</html>
"""
    msg.attach(MIMEText(html, "html", "utf-8"))
    return msg
