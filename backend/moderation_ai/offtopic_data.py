# -*- coding: utf-8 -*-
"""
EcoRewind -- Donnees off_topic enrichies (10 categories)
=========================================================
Technologie, Sport, Sante, Education, Divertissement,
Politique, Economie, Cuisine, Voyage, Mode/Beaute

Ce module est importe par build_text_dataset.py pour remplacer
les listes OFFTOPIC_FR / OFFTOPIC_AR / OFFTOPIC_EN originales.
"""

OFFTOPIC_FR = [
    # --- TECHNOLOGIE / IA / CYBERSECURITE ---
    "ChatGPT vient de sortir une nouvelle version encore plus impressionnante",
    "Mon script Python plante a cause d'une erreur de type, quelqu'un peut m'aider ?",
    "La cybersecurite est devenue le defi numero un des entreprises en 2025",
    "Demo de l'IA generative d'images : les resultats sont incroyables",
    "Nouveau framework JavaScript sorti aujourd'hui, la communaute s'emballe",
    "Fuite de donnees massive : millions de comptes utilisateurs exposes",
    "GitHub Copilot aide les developpeurs a coder deux fois plus vite",
    "Le nouvel iPhone ultra bat tous les records de performance mobile",
    "Conference sur le machine learning : les dernieres avancees en NLP",
    "Ransomware attaque l'hopital, les systemes informatiques paralyses",
    "Meta lance son nouveau casque de realite virtuelle a 300 euros",
    "Les cryptomonnaies s'effondrent : Bitcoin perd 30% en 24h",
    "Tesla annonce une nouvelle batterie avec autonomie de 800 km",
    "Google Gemini depasse GPT-4 sur les benchmarks de raisonnement",
    "Nouveau bug critique dans Windows, patch urgent disponible ce matin",

    # --- SPORT ---
    "Quel match incroyable hier soir ! 3-0 en finale de la Ligue des Champions",
    "Notre equipe nationale se qualifie pour la Coupe du Monde 2026 !",
    "Transfert record : le joueur part pour 200 millions d'euros",
    "Le marathon de Paris : 40 000 coureurs sous un soleil radieux ce dimanche",
    "Finale de Roland-Garros : suspense jusqu'au dernier set ce soir",
    "Mon programme de musculation du lundi : dos et biceps en salle",
    "Blessure grave du joueur star, indisponible pour 3 mois minimum",
    "Nouveau record du monde au 100 metres battu aux Championnats du monde",
    "Le Tour de France debute demain, parcours tres montagneux cette annee",
    "Basket : notre club remporte le titre national pour la 5eme fois",
    "Seance de yoga ce matin, je me sens tellement mieux physiquement",
    "Objectif fitness atteint : 10 kg perdus en 3 mois grace au sport",
    "Rugby : le match d'ouverture du Tournoi des 6 Nations ce soir en direct",

    # --- SANTE / MEDECINE / NUTRITION ---
    "Nouveau vaccin contre la grippe disponible en pharmacie des demain",
    "Regime mediterraneen : les bienfaits sur la sante cardiovasculaire",
    "Mon medecin m'a diagnostique une carence en vitamine D importante",
    "L'OMS alerte sur la resistance aux antibiotiques dans le monde entier",
    "Operation reussie grace a la chirurgie robotique de derniere generation",
    "Jeune intermittent : est-ce vraiment efficace pour perdre du poids ?",
    "Nouveau traitement contre le cancer du sein : taux de guerison 90%",
    "Prise en charge de la depression : les nouvelles therapies cognitives",
    "Diabete type 2 : l'alimentation anti-sucre qui fait la difference",
    "Decouverte d'une proteine cle dans la maladie d'Alzheimer",
    "Stress au travail : 5 techniques de gestion validees scientifiquement",
    "Le chocolat noir ameliore la memoire selon une etude scientifique recente",

    # --- EDUCATION ---
    "Les resultats du baccalaureat : taux de reussite record cette annee",
    "Meilleure methode pour apprendre une langue etrangere en 3 mois",
    "Mon fils vient d'etre admis a l'ecole polytechnique, je suis tres fier",
    "La reforme du systeme educatif divise enseignants et parents d'eleves",
    "MOOC gratuit sur la data science : 50 000 inscrits en 24h seulement",
    "Concours d'entree aux grandes ecoles : les sujets de maths impossibles",
    "Application pour apprendre l'arabe en jouant, tres efficace pour les enfants",
    "Rapport : les eleves passent trop de temps sur les ecrans numeriques",
    "Universite en ligne : diplome reconnu ou simple arnaque payante ?",
    "Le programme Erasmus permet a 400 000 etudiants d'etudier a l'etranger",
    "Intelligence artificielle dans les salles de classe : avantage ou danger ?",

    # --- DIVERTISSEMENT / FILMS / SERIES / MUSIQUE ---
    "La nouvelle saison de cette serie Netflix me tient eveille jusqu'a 3h du matin",
    "Film de l'annee : Oscars 2025, le grand gagnant surprend tout le monde",
    "Nouveau single : deja 50 millions de streams en 48h, c'est un carton",
    "Concert parisien annule a la derniere minute, les fans sont sous le choc",
    "Le jeu video le plus attendu de l'annee sort enfin demain partout",
    "Festival de Cannes : palme d'or pour ce film dramatique absolument bouleversant",
    "Mon livre prefere de l'annee : ce thriller psychologique est totalement haletant",
    "Podcast du moment : l'histoire vraie de cet entrepreneur millionnaire",
    "Avengers 6 bat tous les records au box-office mondial en une seule semaine",
    "Emission de telereelite : les candidats font la polemique sur les reseaux sociaux",
    "Nouveau jeu mobile addictif : 10 millions de telechargements en 3 jours",

    # --- POLITIQUE ---
    "Resultats des elections legislatives : le parti centriste arrive en tete",
    "Scandale politique : le ministre implique dans une affaire de corruption",
    "Discours du Premier ministre sur la reforme fiscale tres controversee",
    "Manifestation nationale contre la reforme des retraites, 1 million de personnes",
    "Sommet du G20 : tensions entre les grandes puissances mondiales",
    "Vote de la loi sur l'immigration au Parlement europeen ce jeudi",
    "Crise diplomatique : deux ambassadeurs rappeles simultanement par leurs pays",
    "Sondage : le president perd 20 points de popularite en un seul mois",
    "Referendum sur l'independance de la region : 52% votent pour le oui",
    "Nouvelle coalition gouvernementale formee apres 3 mois de negociations",

    # --- ECONOMIE / FINANCE / CRYPTO ---
    "La bourse de Paris chute de 4% suite aux mauvais chiffres de l'emploi",
    "Bitcoin franchit le cap des 100 000 dollars pour la toute premiere fois",
    "Inflation : le panier de courses a augmente de 8% en seulement un an",
    "Faillite de la banque regionale : les depots garantis jusqu'a 100 000 euros",
    "Le taux de chomage atteint son plus bas niveau historique depuis 20 ans",
    "Nouveau plan de sauvetage de 50 milliards pour l'industrie automobile",
    "Hausse des taux d'interet : les credits immobiliers deviennent inaccessibles",
    "Start-up valorisee a 2 milliards d'euros sans jamais avoir fait de benefices",
    "Le yuan remplace le dollar dans les echanges petroliers sino-saoudiens",
    "Les NFT s'effondrent : l'heure du bilan apres la grande bulle speculatve",

    # --- CUISINE / GASTRONOMIE ---
    "Ma recette de tajine d'agneau aux pruneaux, un veritable delice familial",
    "Le meilleur restaurant etoile de Paris : reservation 6 mois a l'avance",
    "Comment reussir un souffle au fromage sans qu'il s'effondre a la cuisson",
    "Tendance gastronomique 2025 : la cuisine fermentee a la mode coreenne",
    "Recette rapide du lundi soir : pates carbonara en 15 minutes chrono",
    "Cours de patisserie francaise pour debutants : macarons et tarte tatin",
    "Le guide Michelin revele ses etoiles 2025 : 5 nouveaux restaurants etoiles",
    "Street food marocaine : les meilleures adresses a tester a Marrakech",
    "Recette de couscous royal pour 10 personnes : liste des ingredients",
    "Mon smoothie proteine post-entrainement : banane, whey et beurre de cacahuete",

    # --- VOYAGE / TOURISME ---
    "Week-end a Barcelone : les incontournables entre mer, architecture et tapas",
    "Road trip au Maroc : de Fes a Merzouga en passant par les gorges du Dades",
    "Meilleur hotel de Dubai avec vue sur le Burj Khalifa : notre avis complet",
    "Visa Schengen : les nouvelles regles pour les ressortissants nord-africains",
    "Sejour en Thailande : temples, plages et street food absolument inoubliables",
    "Comparatif des compagnies aeriennes low-cost transatlantiques 2025",
    "Japon : comment survivre a Tokyo avec un budget de 50 euros par jour",
    "Carnet de voyage en Islande : aurores boreales et geysers grandioses",
    "Top 10 des destinations les plus visitees en 2025 selon l'agence mondiale",
    "Alerte aux arnaques dans les hotels de luxe reserves en ligne",

    # --- MODE / VETEMENTS / BEAUTE / COSMETIQUES ---
    "Tendances mode printemps 2025 : le retour du baggy et des couleurs pastels",
    "Collection de maquillage : nouvelles palettes de fards a paupieres tres pigmentees",
    "Rouges a levres, mascaras et eyeliner : les must-have beaute du moment",
    "Fashion week de Paris : les looks les plus fous des defile haute couture",
    "Comparatif des meilleures cremes anti-age du marche testees pendant 3 mois",
    "Mon haul shopping du week-end : Zara, H&M et les meilleures promos",
    "Nouveau parfum lance par cette grande maison de luxe : un succes immediat",
    "Bijoux tendance 2025 : le retour des bagues chunky et des colliers superposes",
    "Soins capillaires naturels : masque a l'huile d'argan pour cheveux secs",
    "Les sneakers les plus stylees de la saison : Nike, Adidas, New Balance",
    "Tutorial maquillage naturel pour le bureau : look frais en 10 minutes",
    "Mode durable : les marques qui misent sur le recyclage des textiles",
]

OFFTOPIC_AR = [
    # Technologie
    "الذكاء الاصطناعي يغزو سوق العمل: ملايين الوظائف مهددة بسبب التطور التقني",
    "تسريب بيانات ضخم يطال شركة تقنية كبرى ويكشف معلومات المستخدمين",
    "احدث اصدار من نظام iOS يحمل مزايا ثورية للمستخدمين الجدد",
    "البيتكوين يعود للارتفاع بعد اسابيع من الانخفاض الحاد في السوق",
    "افضل تطبيقات الهاتف لتعلم البرمجة من الصفر مجانا",
    # Sport
    "مباراة نارية البارحة والفريق تاهل للنهائي بركلات الترجيح",
    "منتخبنا يتاهل الى كاس العالم بعد فوز تاريخي على البطل المدافع",
    "نجم كرة القدم يوقع عقدا خياليا بـ 500 مليون يورو لمدة 4 سنوات",
    "دوري ابطال اوروبا والمفاجات الكبيرة في دور الـ 16 هذا الموسم",
    "برنامج اللياقة البدنية لشهر رمضان وتمارين خفيفة وفعالة للجميع",
    # Sante
    "وزير الصحة يعلن توفر اللقاح الجديد ضد الانفلونزا في المراكز الصحية",
    "دراسة جديدة تكشف ان الصيام المتقطع يحسن الصحة القلبية بشكل ملحوظ",
    "تحذير خطير من تناول المضادات الحيوية دون وصفة طبية من الطبيب",
    "اكتشاف علاج واعد لسرطان الثدي يرفع نسبة الشفاء الى 90%",
    # Education
    "نتائج الثانوية العامة وارتفاع ملحوظ في نسبة النجاح هذا العام",
    "افضل تطبيق لتعلم اللغة الانجليزية في 90 يوما فقط بدون معلم",
    "الجامعة الافتراضية والتساؤل هل الشهادات الرقمية معترف بها في سوق العمل",
    "اصلاح المناهج الدراسية وجدل بين المربين واولياء الامور في الجزائر",
    # Divertissement
    "مسلسل رمضاني يحقق اعلى نسبة مشاهدة في تاريخ القناة الوطنية",
    "حفل موسيقي كبير في مراكش يجمع نجوم الراي والبوب العربي الشهير",
    "فيلم مغربي يفوز بجائزة افضل فيلم عربي في مهرجان القاهرة السينمائي",
    # Politique
    "الانتخابات البرلمانية والحزب الحاكم يحتفظ بالاغلبية رغم المنافسة",
    "ازمة دبلوماسية بين البلدين بعد تصريحات وزير الخارجية المثيرة للجدل",
    # Economie
    "التضخم يقضم القدرة الشرائية للمواطنين وارتفاع الاسعار يقلق الاسر",
    "العملات المشفرة في تراجع حاد هل اقتربت نهاية فقاعة الكريبتو",
    # Cuisine
    "طريقة تحضير كسكس الجمعة بالخضار والدجاج وصفة الجدة الاصيلة",
    "افضل مطاعم فاس المدينة العتيقة واطباق تقليدية بنكهة عصرية جديدة",
    # Voyage
    "السياحة في جورجيا ومدينة تبليسي التي تسحر كل زائر واجنبي",
    "رحلة عائلية الى اسطنبول وافضل الاماكن والفنادق بميزانية معقولة جدا",
    # Mode
    "ازياء الصيف 2025 والالوان الصاخبة والاقمشة الخفيفة تهيمن على الموضة",
    "احمر الشفاه والمسكارا والبرونزر وابرز منتجات الميك اب لهذا الموسم",
]

OFFTOPIC_EN = [
    # Technology / AI / Cybersecurity
    "ChatGPT-5 launches with reasoning capabilities that beat human experts on tests",
    "Major data breach exposes 50 million user accounts at a leading tech company",
    "How to learn Python in 30 days: the best free resources and roadmap online",
    "Apple unveils the M4 chip with a 40% performance boost over the previous M3",
    "Top cybersecurity tips: how to protect yourself from phishing attacks in 2025",
    "Bitcoin hits $100k for the first time ever, crypto markets explode worldwide",
    "Meta's new AR glasses: the future of computing or just an expensive gadget?",
    "GitHub Copilot now writes 40% of code at top tech companies around the world",
    "Quantum computing breakthrough threatens current encryption standards globally",
    # Sport
    "Incredible match last night! 3-0 in the Champions League final, unbelievable",
    "My weekly gym routine: chest, back, and legs split program fully explained",
    "NBA playoffs: the most unexpected upset in years shocks absolutely everyone",
    "How to train for your first 10K run in 8 weeks: a beginner's training guide",
    "World Cup 2026 qualifiers: group standings and top scorers after matchday 7",
    "Fitness challenge: I exercised every day for 30 days and here are my results",
    # Health / Nutrition / Medicine
    "Intermittent fasting results after 90 days: I lost 12 kg and feel amazing",
    "New Alzheimer's treatment shows 60% reduction in cognitive decline in trials",
    "Is the Mediterranean diet really the healthiest lifestyle in the world today?",
    "Vitamin D deficiency: 8 symptoms you might be completely ignoring every day",
    "Mental health at work: how companies are now tackling employee burnout",
    "The best high-protein breakfast options for muscle building and weight loss",
    "New cancer drug approved by FDA: what patients need to know about side effects",
    # Education
    "Best online learning platforms ranked: Coursera vs edX vs Udemy in 2025",
    "How to study effectively using the Feynman technique for very difficult exams",
    "University tuition fees hit record highs across Europe this academic year",
    "My child just got accepted to MIT — proudest parenting moment of my entire life",
    "The impact of AI tools on student academic integrity is a growing serious debate",
    "Learning Arabic from scratch: best apps and methods for complete beginners",
    # Entertainment / Movies / Music / Gaming
    "Season 3 of this Netflix thriller just dropped and I binge-watched everything",
    "Oscars 2025: full list of winners and the biggest surprises of the whole night",
    "Taylor Swift's Eras Tour breaks all-time concert revenue records worldwide",
    "This new video game is so addictive I completely forgot to sleep for two nights",
    "Best K-dramas to watch in 2025: my personal curated top 10 recommendations",
    "The Cannes Film Festival Palme d'Or goes to a very unexpected indie director",
    "New album drops from this iconic band after a 10-year hiatus, worth the wait",
    # Politics
    "Presidential election results: historic voter turnout decides a nation's future",
    "Parliament votes on highly controversial immigration reform bill amid protests",
    "Diplomatic crisis erupts after disputed territorial claims between two nations",
    "New coalition government finally formed after three months of tense talks",
    "Corruption scandal brings down the finance minister in a very surprise move",
    "Opposition party wins a landslide majority in snap elections called by president",
    # Economy / Finance / Crypto
    "Stock markets plunge hard amid fears of an incoming global recession this year",
    "Ethereum major upgrade launches with huge improvements to speed and lower costs",
    "Inflation is destroying household budgets: grocery bills are up 10% this year",
    "The housing market crisis: young people are completely priced out of homeownership",
    "Central bank raises interest rates for the fifth consecutive time this year",
    "Startup raises $500 million in Series C funding despite never turning any profit",
    # Cooking / Gastronomy
    "My grandmother's lamb tagine recipe — the secret ingredient is preserved lemon",
    "The 10 best Michelin-starred restaurants in Paris you absolutely need to visit",
    "How to make perfect croissants at home: a detailed step-by-step baking guide",
    "Korean cuisine is taking over the world — here is exactly why everyone loves it",
    "Meal prep Sunday: 5 healthy and delicious recipes for the entire busy work week",
    "Homemade sourdough bread tutorial: my complete beginner's guide to fermentation",
    # Travel / Tourism
    "Weekend in Barcelona: everything you absolutely must see and do in just 48 hours",
    "Budget travel in Japan: how to visit Tokyo for under 60 dollars a day as tourist",
    "The best hidden beach destinations in the Mediterranean you have never heard of",
    "Road trip in Morocco: from Marrakech to the Sahara desert in 7 amazing days",
    "Travel hack: how to get business class tickets at prices close to economy class",
    "Solo travel in Southeast Asia: safety tips and best destinations for beginners",
    # Fashion / Beauty / Cosmetics
    "Spring 2025 fashion trends: oversized blazers and pastel color palettes are in",
    "My full makeup tutorial using only drugstore products that cost under 50 dollars",
    "Lipstick, mascara, and eyeliner: the top beauty product launches happening now",
    "Best skincare routine for combination skin: complete morning and evening steps",
    "New luxury perfume collection just dropped: here are the top 5 scents to try",
    "Sneaker release alert: the most hyped limited edition drops of the entire season",
    "Fashion week highlights: the most striking looks from the Paris runway shows",
    "Makeup tutorial: how to achieve the glazed donut skin trend step by step",
]
