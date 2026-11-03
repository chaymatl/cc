# -*- coding: utf-8 -*-
"""
EcoRewind -- Donnees off_topic enrichies (18 categories)
=========================================================
Technologie, Sport, Sante, Education, Divertissement,
Politique, Economie, Cuisine, Voyage, Mode/Beaute,
Violence/Accidents, Automobile, Immobilier, Animaux,
Religion (hors-eco), Mariage/Fetes, Jeux/Paris, Buzz/Viral

Ce module est importe par build_text_dataset.py pour remplacer
les listes OFFTOPIC_FR / OFFTOPIC_AR / OFFTOPIC_EN originales.

v2.0 — Ajout de 8 nouvelles categories (200+ exemples supplementaires)
pour améliorer la détection des contenus hors-sujet non-environnementaux.
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

    # ═══════════════════════════════════════════════════════════════════════════
    # NOUVELLES CATEGORIES v2.0
    # ═══════════════════════════════════════════════════════════════════════════

    # --- VIOLENCE / ACCIDENTS / SECURITE ROUTIERE ---
    "Accident de voiture terrible sur l'autoroute, 3 blesses graves transportes",
    "Bagarre eclate en pleine rue filmee et partagee des millions de fois",
    "Attaque au couteau dans le metro, le suspect en fuite recherche par la police",
    "Collision frontale entre deux camions sur la nationale, bilan tres lourd",
    "Rixe violente entre supporters apres le match, plusieurs arrestations",
    "Accident de moto grave : le conducteur helitreuille en urgence a l'hopital",
    "Fusillade dans un centre commercial, la situation encore en cours ce soir",
    "Combat de boxe clandestin filme et diffuse sur les reseaux sociaux viraux",
    "Carambolage monstre sur l'autoroute A7 sous le brouillard : 12 vehicules",
    "Coup de poing filmé en pleine rue devient viral sur TikTok ce matin",
    "Voitures brulees dans le quartier apres les affrontements nocturnes violents",
    "Choc violent entre deux motos : les conducteurs projetes sur la chaussee",
    "Embuscade filmee : groupe attaque passant dans une ruelle sombre la nuit",
    "Dramatique accident de train : deraillement cause par un camion sur les rails",
    "Violence conjugale filmee et partagee : les associations appellent a reagir",

    # --- AUTOMOBILE / MECANIQUE / TUNING ---
    "Mon nouveau SUV vient d'arriver chez le concessionnaire, je suis trop content",
    "Comparatif des meilleures voitures electriques 2025 : Tesla vs Renault vs BMW",
    "Tuning extreme : cette berline transformee en monster truck fait le buzz",
    "Panne de moteur a 200 km de chez moi : que faire sans assistance routiere ?",
    "Nouveau modele Ferrari 2025 presente au salon de Geneve : prix et specs",
    "Mon mecano a trouve une fuite d'huile : devis de 800 euros pour la reparation",
    "Les meilleures huiles moteur pour prolonger la vie de votre vehicule diesel",
    "Essai routier : 48h au volant du nouveau pickup americain tout-terrain",
    "Vendre ma voiture d'occasion : ou afficher l'annonce pour un prix maximum ?",
    "Accident de la route simule pour escroquer l'assurance : 5 ans de prison",
    "Course illegale sur autoroute : 300 km/h filmes par dashcam embarquee",
    "Rappel constructeur : ces modeles doivent etre controles d'urgence au garage",
    "Mon quad personnalise avec led et systeme son : le travail de 6 mois montre",
    "Kit de carrosserie pour Clio 4 : montage complet en video tutoriel detaille",

    # --- IMMOBILIER / LOGEMENT / DEMENAGEMENT ---
    "Appartement F3 a vendre dans le centre-ville : 185 000 euros, tres bon etat",
    "Louer ou acheter en 2025 ? Le calcul complet pour faire le bon choix financier",
    "Mon demenagement cauchemardesque : les demenageurs ont casse ma television",
    "Investissement locatif : comment acheter sans apport grace au deficit foncier",
    "Prix de l'immobilier en chute libre dans ces 10 villes francaises cet automne",
    "Renovation de salle de bain : mon budget de 5000 euros et le resultat final",
    "Colocation entre etudiants : mes conseils pour eviter les conflits au quotidien",
    "Visite guidee de mon studio 25m2 optimise avec des meubles Ikea malines",
    "Arnaque immobiliere : le proprietaire encaisse le depot de garantie et disparait",
    "Logement social : liste d'attente de 8 ans dans cette grande agglomeration",

    # --- ANIMAUX DE COMPAGNIE / FAUNE URBAINE ---
    "Mon chat a mange quelque chose de bizarre dans le jardin, dois-je m'inquieter ?",
    "Adopter un chien adulte : les avantages par rapport aux chiots selon les vets",
    "Mon aquarium de 200 litres : les poissons tropicaux que j'ai choisis et pourquoi",
    "Serpent retrouve dans une maison du quartier, les pompiers interviennent rapidement",
    "Race de chien ideale pour appartement : comparatif des meilleures races calmes",
    "Mon perroquet repete des insultes, comment le reeduquer gentiment chez soi ?",
    "Invasion de fourmis dans la cuisine : les solutions naturelles et chimiques testees",
    "Nouvelle loi sur les chiens dangereux : ce qui change pour les proprietaires",
    "Chat abandonne retrouve apres 3 ans par sa famille grace aux reseaux sociaux",
    "Prix exorbitant du veterinaire : faut-il souscrire a une assurance animaux ?",

    # --- MARIAGE / EVENEMENTS / FETES FAMILIALES ---
    "Decoration de mariage orientale : les idees les plus belles et tendance 2025",
    "Mon budget mariage de 15 000 euros : comment le repartir intelligemment ?",
    "Robe de mariee sur mesure : 6 mois de preparation pour ce grand jour reve",
    "Organisation d'une henna party : les traditions et la liste des invitations",
    "Buffet de mariage pour 200 personnes : traiteur ou fait maison, que choisir ?",
    "Enterrement de vie de garcon a Budapest : programme complet et budget total",
    "Photographe mariage : comment choisir le bon pour immortaliser votre jour J ?",
    "Cadeau de mariage original : nos meilleures idees pour un couple moderne",
    "Baby shower surprise organizee pour ma soeur : decor pastel et jeux amusants",
    "Anniversaire de 40 ans : soiree surprise organisee avec 80 invites secrets",

    # --- RELIGION / SPIRITUALITE (hors contexte eco) ---
    "Priere du vendredi : rappel des conditions et de l'importance pour les musulmans",
    "Ramadan 2025 : horaires de l'imsak et du ftour ville par ville en temps reel",
    "Pelerinage a La Mecque : conseils pratiques pour les primo-pelerins hajj 2025",
    "Messe de Noel retransmise en direct de la basilique Saint-Pierre de Rome",
    "Les fetes juives du calendrier 2025 : dates et significations expliquees",
    "Meditations bouddhistes du matin pour trouver la paix interieure au quotidien",
    "Jeune du Yom Kippour : regles, traditions et rupture du jeune expliquees",
    "Commemoration de l'Achoura : rites et pratiques selon les differentes traditions",

    # --- JEUX D'ARGENT / PARIS SPORTIFS / CASINO ---
    "Pronostic match de demain : les meilleures cotes sur les bookmakers en ligne",
    "J'ai gagne 5000 euros au casino en ligne hier soir grace a cette strategie",
    "Paris sportifs : l'essentiel pour debuter sans perdre trop d'argent au depart",
    "Machine a sous en ligne : les meilleurs casinos avec bonus sans depot en 2025",
    "Poker en ligne : les erreurs des debutants que vous devez absolument eviter",
    "Loterie nationale : le gagnant du jackpot de 30 millions refuse de se montrer",
    "Scratch : est-ce vraiment une methode rentable sur le long terme ou une arnaque ?",

    # --- BUZZ / VIRAL / INSOLITE / TENDANCES ---
    "Cette video de chute spectaculaire fait 100 millions de vues en seulement 24h",
    "Challenge TikTok viral : des milliers de jeunes le reproduisent a travers le monde",
    "Cet homme a mange 100 hamburgers en une semaine pour battre un record insolite",
    "Drôle de situation : ce chien conduit une voiture et la video devient virale",
    "Tatouage raté devient meme mondial : l'histoire derriere ce fail artistique total",
    "Fail du week-end : ce gars tente de sauter dans la piscine et atterrit a cote",
    "Ce couple se rencontre sur Tinder et decouvre qu'ils sont cousins par hasard",
    "Video choc : ce serpent avale un crocodile entier en plein Outback australien",
    "Ce bebe dit son premier mot a 5 mois et la video devient virale internationalement",
    "Insolite : cet homme vit dans un supermarche depuis 6 mois sans se faire reperer",
    "Ce chat joue du piano et la communaute musicale est completement sous le choc",
    "Humour noir virale : cette blague sur les politiciens brise tous les records",
    "Prank extreme : il fait croire a sa femme qu'un serpent est dans leur maison",
    "Reaction en chaine : un domino de 100 000 pieces tombe en 10 secondes chrono",
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

    # ═══════════════════════════════════════════════════════════════════
    # NOUVELLES CATEGORIES AR v2.0
    # ═══════════════════════════════════════════════════════════════════

    # Violence / Accidents
    "حادث سيارة مروع على الطريق السريع وثلاثة مصابين في حالة حرجة جداً",
    "شجار عنيف بين مجموعتين في الشارع ومقاطع الفيديو تنتشر بسرعة مذهلة",
    "هجوم بالسكين في المترو والمشتبه به لا يزال طليقاً يبحث عنه الأمن",
    "تصادم سيارتين بسرعة جنونية وحريق اندلع على الفور في الطريق",
    "فيديو مروع لشخص يقع من الطابق الثالث وينجو بأعجوبة من الموت",
    "مطاردة بوليسية مثيرة انتهت بحادث مروع في وسط المدينة المزدحمة",
    "ضرب وإيذاء في الملعب بعد نهاية المباراة وتدخل قوات الأمن",

    # Automobile
    "سيارتي الجديدة وصلت أخيراً وهذا هو استعراض كامل للمواصفات",
    "مقارنة أفضل السيارات الكهربائية في السوق العربية لعام 2025",
    "عطل في المحرك في منتصف الطريق ولا أحد يمر هنا للمساعدة",
    "تعديلات رياضية على سيارتي الخاصة استغرقت مني ستة أشهر كاملة",
    "أسعار السيارات الجديدة ترتفع 20 بالمئة مقارنة بالعام الماضي",

    # Immobilier
    "شقة للبيع في قلب المدينة بسعر مناسب والتفاصيل في التعليقات",
    "الإيجار أم الشراء في 2025 وكيف تتخذ القرار الصحيح لمستقبلك",
    "تجربة الانتقال إلى منزل جديد وأكثر الأشياء التي أنسيتها وندمت",
    "أسعار العقارات ترتفع بشكل جنوني في المدن الكبرى ولا حل في الأفق",
    "تحويل الشقة القديمة إلى فضاء عصري بميزانية محدودة جداً وأفكار ذكية",

    # Animaux
    "قطتي مريضة ولا أعرف ما الذي أكلته من الحديقة هذا الصباح",
    "تبني كلب بالغ أفضل من الجرو وإليك الأسباب العلمية المقنعة",
    "أسماك الزينة في حوضي الجديد وكيف اخترت الأنواع المناسبة",
    "اكتشاف ثعبان داخل منزل في الحي والأهالي يطلبون تدخلاً عاجلاً",
    "سعر الطبيب البيطري مرتفع جداً هل التأمين على الحيوانات يستحق ؟",

    # Mariage / Fetes
    "تحضيرات حفل زفافي بعد ستة أشهر وهذه هي أهم التفاصيل والأسرار",
    "ميزانية الزفاف ثمانية آلاف دولار وكيف قسمناها على التفاصيل",
    "فستان العروس المخصص استغرق أربعة أشهر من العمل والتصميم المميز",
    "حفل الحناء وكيف نظمنا كل التفاصيل التقليدية بطريقة عصرية رائعة",
    "عيد ميلاد مفاجأة لوالدتي مع خمسين ضيفاً ولم تكن تعلم بشيء",

    # Religion
    "مواقيت الصلاة في رمضان المبارك وجدول الإمساك والإفطار لكل المدن",
    "فضل الصيام في العشر الأواخر من رمضان وما ورد في الأحاديث النبوية",
    "نصائح للحج هذا العام وما يجب معرفته قبل التوجه للأراضي المقدسة",
    "الدعاء المأثور قبل النوم والذكر الذي يحمي من الشيطان الرجيم",

    # Jeux / Paris
    "توقعاتي لمباريات اليوم وأفضل الرهانات على المواقع المتاحة",
    "ربحت ألفي دولار من القمار الإلكتروني الليلة بهذه الطريقة السرية",
    "أفضل مواقع الرهانات الرياضية العربية المرخصة والآمنة في 2025",

    # Buzz / Viral
    "مقطع سقوط مضحك يحقق مئة مليون مشاهدة في يوم واحد فقط",
    "تحدي تيك توك الجديد ينتشر بشكل جنوني بين الشباب في العالم",
    "هذا الرجل أكل مئة برغر في أسبوع وهذه نتائج الفحص الطبي",
    "فيديو فيروسي لقطة تقود سيارة لوحدها ويضحك عليها الملايين",
    "خطأ في الوشم يصبح ميماً عالمياً في غضون ساعات قليلة جداً",
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

    # ═══════════════════════════════════════════════════════════════════
    # NEW CATEGORIES EN v2.0
    # ═══════════════════════════════════════════════════════════════════

    # Violence / Accidents / Road Safety
    "Horrific car crash on the highway leaves 3 critically injured and 1 dead",
    "Street brawl caught on camera goes viral with over 20 million views overnight",
    "Knife attack in the subway leaves 2 wounded as police hunt for the suspect",
    "Brutal fight between rival fan groups erupts outside the stadium after the match",
    "Shocking dashcam footage captures a head-on collision at high speed on the road",
    "Road rage incident escalates into a violent assault captured on phone cameras",
    "Mass shooting at a shopping mall: police response and victim count still rising",
    "Illegal street racing at 200mph caught on camera ends in a massive fireball crash",
    "Domestic violence video goes viral: advocates call for urgent government action",
    "Bar fight leaves 5 hospitalized after a brawl erupts following a football game",
    "Motorcycle accident victim airlifted to hospital after a high-speed collision",
    "CCTV footage shows armed robbery at a jewelry store in broad daylight downtown",

    # Automobile / Cars / Mechanics
    "My brand new SUV just arrived at the dealership — here's the full unboxing",
    "Tesla vs BMW vs Rivian: the ultimate electric car comparison for 2025 buyers",
    "My car broke down 200 miles from home and there's no roadside assistance here",
    "Extreme car modification: turning a regular sedan into a monster truck build",
    "The best motor oils for extending the life of your diesel engine in cold weather",
    "New Ferrari 2025 model revealed at the Geneva Motor Show: specs and price list",
    "Illegal street race at 300 km/h caught on dashcam: driver faces serious charges",
    "Full car restoration: transforming a 1970s rust bucket into a show-stopping gem",
    "Car recall notice: these specific models must be checked urgently by the dealer",
    "How to sell your used car for maximum value: tips from an experienced car dealer",

    # Real Estate / Housing
    "3-bedroom apartment for sale in city center: 250,000 USD, great condition",
    "Rent or buy in 2025? A complete financial breakdown to help you decide smartly",
    "My moving nightmare: the movers broke my TV and now refuse to pay damages",
    "How to invest in real estate with no down payment using creative finance tricks",
    "Property prices are crashing in these 10 major cities — huge opportunity now",
    "Bathroom renovation on a $5,000 budget: before and after transformation photos",
    "Student housing crisis: waiting lists of 8 years in major university cities",
    "My 25 sqm studio apartment tour: how I maximized every single inch of space",

    # Pets / Animals
    "My cat ate something strange in the garden — should I take her to the vet now?",
    "Adopting an adult dog vs a puppy: the 10 reasons adult dogs make better pets",
    "My 200-liter tropical fish tank setup: the species I chose and why I love them",
    "Snake found inside a family home in the neighborhood — fire brigade called in",
    "Is pet insurance worth the cost? A complete breakdown of what it actually covers",
    "My parrot keeps repeating curse words — how do I teach him better vocabulary?",
    "Ant invasion in my kitchen: natural vs chemical solutions put to the test",

    # Wedding / Events / Celebrations
    "My wedding decoration ideas: the most beautiful oriental styles trending in 2025",
    "Wedding budget breakdown: how we spent $15,000 on our dream wedding day",
    "Our custom wedding dress took 6 months to make — here's the full behind-the-scenes",
    "Bachelorette party in Budapest: full itinerary and budget for 8 people",
    "Wedding photographer: how to choose the right one to capture your perfect day",
    "Surprise 40th birthday party with 80 secret guests — here's how we pulled it off",

    # Religion / Spirituality (non-eco)
    "Friday prayer guide: conditions and importance explained for new Muslims",
    "Ramadan 2025 fasting schedule: city-by-city iftar and suhoor times worldwide",
    "Hajj pilgrimage tips: everything first-timers need to know before traveling",
    "Christmas mass live from St. Peter's Basilica in Vatican City this year",
    "Morning Buddhist meditations to find inner peace in your daily life routine",
    "Yom Kippur fasting: rules, traditions and how to break the fast properly",

    # Gambling / Betting / Casino
    "My sports betting predictions for tonight's matches and the best odds available",
    "I won $5,000 at an online casino last night using this specific strategy method",
    "Best online slots with no-deposit bonuses: the top 10 casinos ranked in 2025",
    "Poker mistakes beginners make and exactly how to avoid them for more wins",
    "National lottery winner refuses to reveal identity despite a $30 million jackpot",

    # Viral / Buzz / Trending
    "This spectacular fail video just hit 100 million views in under 24 hours online",
    "New TikTok challenge goes viral: millions of teenagers worldwide are attempting it",
    "Man eats 100 burgers in one week to break a world record — here are the results",
    "Funny video of a dog driving a car goes massively viral across every platform",
    "Tattoo fail becomes a worldwide meme within hours of being posted online",
    "This couple met on Tinder and then discovered they are distant cousins by chance",
    "Shocking clip: snake swallows a whole crocodile in the Australian Outback",
    "Baby says first word at 5 months old and the video breaks all internet records",
    "Man lives inside a supermarket for 6 months without being noticed by anyone",
    "Extreme domino chain reaction: 100,000 pieces fall in just 10 incredible seconds",
    "Prank gone wrong: man convinces wife there's a snake in the house for a laugh",
]
