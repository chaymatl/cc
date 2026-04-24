"""
EcoRewind -- Générateur de dataset texte pour entraînement CNN
==============================================================
Génère ~9 000 exemples labellisés (FR/AR/EN).

Classes :
  eco       → publications environnementales valides
  off_topic → contenu sans lien avec l'écologie
  toxic     → insultes, anti-env, discours haineux

Usage :
    python -X utf8 moderation_ai/build_text_dataset.py
Output :
    moderation_ai/data/text_dataset.csv
"""

import csv, os, random, sys

# Enriched off_topic data (10 categories: Tech, Sport, Health, Education,
# Entertainment, Politics, Economy, Cooking, Travel, Fashion)
try:
    _here = os.path.dirname(os.path.abspath(__file__))
    sys.path.insert(0, os.path.dirname(_here))
    from moderation_ai.offtopic_data import (
        OFFTOPIC_FR as _OT_FR,
        OFFTOPIC_AR as _OT_AR,
        OFFTOPIC_EN as _OT_EN,
    )
    _OFFTOPIC_ENRICHED = True
except ImportError:
    _OFFTOPIC_ENRICHED = False

random.seed(42)
_HERE = os.path.dirname(os.path.abspath(__file__))
OUT   = os.path.join(_HERE, "data", "text_dataset.csv")

# ═══════════════════════════════════════════════════════════════════════════════
# CLASSE ECO -- Publications citoyennes environnementales valides
# ═══════════════════════════════════════════════════════════════════════════════

ECO_FR = [
    "J'ai trié mes déchets aujourd'hui au point de collecte du quartier !",
    "Nettoyage de la forêt ce matin avec les associations locales, 200kg ramassés",
    "Plantation de 30 arbres dans notre quartier pour reverdir la ville",
    "Installation de panneaux solaires sur notre immeuble, -40% d'électricité",
    "Compostage de mes déchets organiques cette semaine, zéro déchet !",
    "Ramassage des déchets sur la plage avec nos voisins, bravo la communauté",
    "Tri sélectif activé dans notre école, les enfants apprennent le recyclage",
    "Biodiversité préservée : arrivée des hirondelles dans notre jardin naturel",
    "Dépôt de piles et batteries au point propre de la commune",
    "Éco-quartier : le bac de compostage collectif est opérationnel !",
    "Reboisement en cours : 500 arbres plantés sur les collines déboisées",
    "Collecte de plastique sur les berges de la rivière, eau plus propre",
    "Panneaux photovoltaïques installés : première facture d'électricité verte",
    "Mon jardin potager bio fonctionne depuis 3 ans, zéro pesticide",
    "Ramassage hebdomadaire des déchets au parc naturel municipal",
    "Atelier recyclage pour les enfants : fabriquer des jouets avec du carton",
    "Éolienne communautaire approuvée, l'énergie renouvelable arrive au village",
    "Réduction de 60% de nos déchets plastiques grâce au vrac",
    "Reforestation : 100 chênes replantés dans la zone déboisée",
    "Collecte de vêtements usagés pour réduire les déchets textiles",
    "Marché bio de proximité ouvert : 0 plastique, tout en vrac",
    "Inauguration du jardin partagé écologique du quartier",
    "Dépôt d'équipements électroniques au centre de recyclage municipal",
    "Réseau de ruches urbaines pour protéger les pollinisateurs",
    "Eau de pluie récupérée pour arroser le jardin, 0 gaspillage",
    "Vélo cargo collectif pour livraisons écologiques en centre-ville",
    "Zéro déchet à la cantine scolaire grâce au compostage",
    "Faune sauvage de retour : renards et hérissons dans notre parc",
    "Isolation thermique naturelle posée, -50% de chauffage cet hiver",
    "Journée mondiale de l'environnement célébrée par notre association",
    "Plantation de haies bocagères pour les oiseaux et insectes",
    "Centre de tri sélectif modernisé, maintenant 12 catégories de déchets",
    "Éco-geste du mois : fin des bouteilles plastiques jetables au bureau",
    "Sentier nature créé pour sensibiliser à la biodiversité locale",
    "Dépôt de pneus usagés au point de collecte spécialisé",
    "Flore locale replantée dans le talus pour les papillons",
    "Chantier de nettoyage du canal avec 50 bénévoles ce samedi",
    "Notre commune vise le zéro plastique d'ici 2026",
    "Semences locales échangées pour préserver les variétés anciennes",
    "Mer propre : 3 tonnes de déchets retirées des fonds marins",
    "Initiative zéro déchet dans notre immeuble, résultat : -80% poubelles",
    "Premier mois sans voiture, on utilise le vélo et les transports en commun",
    "Déchetterie participative ouverte ce week-end, venez nombreux !",
    "Potager communautaire partagé entre 20 familles du quartier",
    "Achat groupé de composteurs pour toute la résidence",
    "Sensibilisation à la biodiversité marine lors de la journée des océans",
    "Collecte de bouchons de liège pour financer des fauteuils roulants",
    "Le marché zéro déchet de notre ville attire de plus en plus de monde",
    "Plantation de lavande pour attirer les abeilles sauvages",
    "Repair café ce dimanche : réparez vos appareils plutôt que de les jeter",
    "Réduction de 30% de la consommation d'eau grâce aux économiseurs",
    "Nettoyage des sentiers de randonnée avec le club de montagne local",
    "Compost partagé entre voisins, réduction de 50% des biodéchets",
    "Toiture végétalisée sur notre école maternelle, îlot de fraîcheur",
    "Achat de produits locaux et de saison pour réduire l'empreinte carbone",
    "Rénovation énergétique de la mairie terminée, bâtiment BBC désormais",
    "Plantations sauvages dans les délaissés urbains pour la biodiversité",
    "Collecte de capsules de café pour recyclage en aluminium",
    "Journée sans viande à la cantine, 200kg de CO2 économisés",
    "Mise en place d'une fontaine à eau publique pour éviter les bouteilles",
    "Protection des zones humides : les grenouilles sont de retour !",
    "Balade nature organisée pour observer les oiseaux migrateurs",
    "Tri des biodéchets obligatoire dans notre ville depuis ce mois-ci",
    "Planting 50 trees with our school children for a greener neighborhood",
    "Notre association plante 1 arbre pour chaque publication écologique !",
    "Bravo à tous les bénévoles du nettoyage de la plage ce matin",
    "L'éco-pâturage de notre commune préserve les prairies naturelles",
    "Apiculture urbaine : nos 4 ruches sur le toit produisent du miel local",
    "Festival zéro déchet organisé par la mairie, venez nombreux !",
    "Ramassage des mégots de cigarette avec l'association locale",
    "Nouveau bac jaune installé dans notre rue, le tri est facilité",
    # ── Nouveaux exemples v3 : action éco + pollution documentée ──
    "Stop à la pollution ! Nettoyons notre littoral ensemble ce samedi",
    "Mobilisons-nous pour ramasser les déchets dans le parc municipal",
    "Protégeons notre rivière : campagne de dépollution ce week-end",
    "Agissons maintenant contre les décharges sauvages, signalons-les",
    "Venez participer au grand nettoyage de printemps dans notre quartier",
    "Recyclons ensemble : chaque bouteille plastique compte",
    "Préservons la forêt : plantation d'arbres fruitiers dimanche",
    "Sauvegardons notre biodiversité marine en nettoyant les plages",
    "Engageons-nous pour réduire nos déchets plastiques de moitié",
    "Combattons la pollution des sols avec le compostage communautaire",
    "Arrêtons le gaspillage alimentaire : atelier cuisine anti-gaspi",
    "Luttons contre la déforestation en replantant des arbres locaux",
    "Rejoignez notre équipe de bénévoles pour la propreté du quartier",
    "Participez à la collecte de déchets électroniques ce dimanche",
    "Notre communauté a réduit ses déchets de 40% grâce au tri sélectif",
    "Le reboisement avance : 1000 arbres plantés depuis janvier",
    "Ensemble, dépolluer cette zone industrielle abandonnée",
    "Campagne de sensibilisation au recyclage dans les écoles primaires",
    "Opération plage propre : résultats impressionnants avec 500 bénévoles",
    "Installation de nichoirs pour les oiseaux dans le parc naturel",
    # ── Darija / dialecte algérien ──
    "Nettoyage dial lplage, 3la slama a lbiaa",
    "Wlad lhouma ramsaw lmzabel, bravo lihom",
    "Tri dyal les dechets fi dar, chaque geste yhseb",
    "Plantation dyal chjar f lhouma, zwin bezzaf",
    "Recyclage dyal plastique maa lassociation",
]

# Salutations et conseils citoyens -- acceptés par la communauté EcoRewind
ECO_GREETINGS_FR = [
    "Bonjour à tous ! Pensez à trier vos déchets aujourd'hui",
    "Bonjour la communauté ! Petit rappel : recyclez le verre et le plastique",
    "Salut tout le monde ! N'oubliez pas de ramasser les déchets si vous en voyez",
    "Bonsoir ! Un petit geste chaque jour pour une planète plus propre",
    "Bonjour ! Aujourd'hui j'ai trié mes déchets, et vous ?",
    "Salam ! Pensez à protéger la nature autour de vous",
    "Hello ! Petit conseil : utilisez des sacs réutilisables au marché",
    "Bonjour la famille EcoRewind ! Ensemble pour un environnement plus propre",
    "Salut ! Astuce du jour : le compost réduit de 30% vos poubelles",
    "Bonsoir à tous ! Chaque geste compte pour préserver notre planète",
    "Bonjour ! Saviez-vous que recycler une canette économise 95% d'énergie ?",
    "Bonjour communauté ! Rappel : les piles se déposent en point de collecte",
    "Salut ! Conseil rapide : éteignez les lumières en quittant une pièce",
    "Bonjour ! Ce week-end nettoyage de quartier, qui est partant ?",
    "Bonsoir la communauté verte ! Merci pour tous vos engagements écologiques",
    "Bonjour à tous, partagez vos bonnes pratiques environnementales ici !",
    "Salam à toute la communauté ! Ensemble on protège notre belle nature",
    "Bonjour ! Le saviez-vous : 1 kg de papier recyclé sauve 17 arbres !",
    "Bonjour citoyens ! N'oubliez pas : proprete de la ville commence par chacun",
    "Salut ! Astuce : une douche courte économise 50L d'eau vs un bain",
]

ECO_GREETINGS_AR = [
    "السلام عليكم ! تذكروا فرز النفايات اليوم لبيئة أنظف",
    "مرحبا بالجميع ! نصيحة اليوم : استخدموا الأكياس القماشية بدل البلاستيك",
    "صباح الخير ! كل يوم نبدأ بنظافة محيطنا معاً",
    "مساء الخير ! لا تنسوا: النفايات في مكانها الصحيح دائماً",
    "السلام عليكم ورحمة الله ! هل تعلمتم اليوم شيئاً جديداً عن البيئة ؟",
    "مرحباً بمجتمع EcoRewind ! معاً نحمي طبيعتنا الجميلة",
    "صباح النور ! نصيحة بيئية : قللوا من استخدام الماء عند تنظيف الأسنان",
    "أهلاً بالجميع ! أصغر الأفعال تصنع أكبر الفروق للبيئة",
]

ECO_GREETINGS_EN = [
    "Hello everyone! Remember to sort your waste today for a cleaner planet",
    "Good morning! Tip of the day: use reusable bags when shopping",
    "Hi community! Every small eco-gesture matters, keep it up!",
    "Good evening! Did you know recycling one glass bottle saves enough energy for 4 hours of light?",
    "Hello! Quick reminder: drop off your batteries at the collection point",
    "Hi all! Let's keep our neighborhood clean together this weekend",
    "Good morning EcoRewind family! Share your green tips below",
    "Hello! Eco tip: a short shower saves 50L of water vs a bath",
    # ── Nouveaux greetings v3 ──
    "Bonjour ! Pensez à éteindre les lumières quand vous sortez",
    "Salut ! Un geste simple : refuser les sacs plastiques au magasin",
    "Bonsoir la communauté ! Comment avez-vous contribué à l'environnement aujourd'hui ?",
    "Bonjour ! Astuce zéro déchet : emportez votre gourde partout",
    "Hello friends! Did you recycle today? Every action counts!",
    "Salam ! Conseil du jour : plantez un arbre pour chaque anniversaire",
    "Bonjour ! Rappel : les médicaments périmés se déposent en pharmacie",
    "Hi! Green tip: use both sides of paper before recycling it",
]

# Pollution documentée + texte encourageant -- acte éco valide
ECO_POLLUTION_DOC_FR = [
    "Regardez cet état ! Déchets partout dans le parc. Faut-il rester indifférents ? Non, agissons !",
    "Photo choc : la plage recouverte de plastique. Rejoignez-nous samedi pour le nettoyage !",
    "C'est honteux ! Décharge sauvage en pleine forêt. Signalons-la à la mairie ensemble",
    "Ce ruisseau pollué me brise le cœur. C'est pour ça qu'on se bat pour l'environnement",
    "Avant / Après : regardez la différence après notre nettoyage communautaire hier !",
    "Cette pollution plastique doit cesser. Chacun peut agir : triez, recyclez, sensibilisez",
    "Inacceptable : ordures jetées dans la nature. Partagez pour sensibiliser tout le monde",
    "Pollution visible ici. Rappel : jeter dans la nature est une infraction punissable",
    "Ces images de pollution nous motivent encore plus à agir. Ensemble on peut nettoyer ça !",
    "Témoignage : déchets abandonnés près de l'école. Mobilisons-nous pour ramasser !",
    "La pollution que j'ai photographiée aujourd'hui me rappelle pourquoi EcoRewind est important",
    "Désolant de voir ça, mais ça nous motive ! Rejoignez l'action de nettoyage dimanche",
    "Regardez ces ordures dans notre rivière. Ensemble, on peut changer ça ! Qui est avec moi ?",
    "Cette photo de pollution m'a choqué. Partagez pour sensibiliser votre entourage",
    "Dépôt sauvage signalé. La nature mérite mieux. Agissons maintenant collectivement",
]

ECO_POLLUTION_DOC_AR = [
    "صورة مؤلمة: النفايات في كل مكان. لكن معاً سننظف هذه المنطقة قريباً",
    "هذا التلوث مؤلم للقلب لكنه يزيدنا إصراراً على الحفاظ على البيئة",
    "انظروا إلى هذه النفايات ! هذا سبب مشاركتنا في حملات النظافة",
    "صورة صادمة : تلوث البحر بالبلاستيك. هل ستتركون الأمر هكذا ؟ انضموا للعمل",
    "شاهدوا هذا التلوث في غابتنا وشاركوا لنوعية الجميع بخطورة رمي النفايات",
]

ECO_POLLUTION_DOC_EN = [
    "Heartbreaking photo of pollution in our park. This is why we fight for a cleaner environment!",
    "Look at this plastic pollution on our beach. Join us Saturday for the big cleanup!",
    "Shameful illegal dumping in the forest. Let's report it and clean it together",
    "This polluted river breaks my heart. That's why our community action matters so much",
    "Before/after photos of our cleanup. This is what community action looks like!",
    "Documenting pollution so we never forget why we do this. Together we can fix it",
    "Plastic waste everywhere. Share to raise awareness — every post counts for change",
    "Shocking pollution found today. Reminder: littering is an offense — report it!",
]

ECO_AR = [
    "قمنا بتنظيف الشاطئ اليوم وجمعنا الكثير من النفايات لحماية البيئة",
    "زرعنا أشجاراً في حيّنا للتشجير وتحسين جودة الهواء",
    "برنامج إعادة التدوير في مدرستنا يعمل بشكل رائع",
    "جمعنا النفايات البلاستيكية من الشاطئ مع المجموعة البيئية",
    "تركيب الألواح الشمسية على سطح المنزل، الآن نستخدم الطاقة النظيفة",
    "يوم تطوعي لنظافة الغابة مع أبناء الحي",
    "فرز النفايات أصبح عادة يومية لدى عائلتنا",
    "حديقة المجتمع البيئية تفتح أبوابها للجميع",
    "حملة تشجير ناجحة: 200 شجرة زرعت في المنطقة",
    "الحفاظ على التنوع البيولوجي في منطقتنا الطبيعية",
    "تجميع البطاريات المستعملة للتخلص منها بشكل صحيح",
    "مبادرة 'طاقة شمسية للجميع' تنطلق في حينا",
    "حوض الكومبوست أُنشئ في حديقتنا لتقليل النفايات العضوية",
    "نظافة النهر: فريق التطوّع يعمل كل أسبوع",
    "إعادة تدوير الورق والكرتون في مكتبنا بشكل منتظم",
    "حملة التوعية البيئية في مدرستنا حققت نتائج رائعة",
    "تحويل النفايات العضوية إلى سماد طبيعي لحديقتنا",
    "استبدال الأكياس البلاستيكية بأكياس قماشية قابلة لإعادة الاستخدام",
    "مبادرة توفير المياه في منزلنا وفّرت 40% من الاستهلاك",
    "حديقة الأسطح الخضراء لتبريد المبنى وتحسين جودة الهواء",
    "مشروع طاقة الرياح الجماعي يوفر الكهرباء لـ 100 منزل",
    "تنظيف واد القرية من القمامة مع شباب الحي",
    "المحافظة على الطيور المهاجرة في منطقتنا الطبيعية",
    "زراعة الخضروات العضوية في حديقة المجتمع",
    "مشاركة في مبادرة 'يوم بدون سيارة' لتقليل التلوث",
    "إزالة النباتات الغازية وإعادة زراعة النباتات المحلية",
    "مبادرة تقليل الطعام المهدر في منزلنا: صفر نفايات غذائية",
]

ECO_EN = [
    "Beach cleanup this morning with local volunteers, amazing community!",
    "Tree planting day at our school, 50 trees planted for a greener future",
    "Started composting at home, already reducing food waste by 70%",
    "Solar panel installation complete, generating clean energy for our home",
    "Community recycling drive collected 500kg of plastics this weekend",
    "Participating in the urban biodiversity monitoring program",
    "Zero waste challenge completed! No landfill waste for 30 days",
    "Car-free zone launched in our neighborhood, reducing air pollution",
    "Set up a rainwater collection system to water the garden",
    "Joined the local conservation project protecting native plant species",
    "Rooftop garden installed to reduce urban heat island effect",
    "E-waste collection event: responsible disposal of old electronics",
    "River water quality improved after community cleanup efforts",
    "Installed energy-efficient LED lighting across the entire building",
    "Wildflower meadow created to support local bee populations",
    "Sorted all plastic, glass, and paper at home today -- recycling matters!",
    "Electric vehicle charged using 100% solar energy this week",
    "Planted 20 native trees to restore the degraded hillside area",
    "Community composting bin set up for the neighborhood",
    "Reduced single-use plastic consumption by switching to reusable bags",
    "Installed a grey water recycling system, saving 40% water usage",
    "Participated in the local bird count to track biodiversity",
    "Repaired old electronics at the fix-it café instead of throwing them away",
    "Switched to a plant-based diet, reducing my carbon footprint by 50%",
    "Joined the river cleanup -- collected 30kg of litter from the riverbank",
    "Launched a school garden program to teach kids about sustainable food",
    "Composting kitchen scraps and using the compost for community gardens",
    "Zero packaging grocery shopping this month -- bulk store is amazing",
    "Organized a neighborhood swap event to extend the life of clothes",
    "Installed smart home energy management to reduce electricity waste",
    # ── Nouveaux eco EN v3 ──
    "Cleaned up the hiking trail and removed 15 bags of garbage",
    "Our school banned single-use plastics and switched to reusable cups",
    "Built an insect hotel to support local pollinators in the garden",
    "Planted native wildflowers along the roadside for biodiversity",
    "Collected ocean plastic to make recycled art with the community",
    "Switched our office to 100% renewable energy this quarter",
    "Volunteered at the wetland restoration project this morning",
    "Reduced food waste by 80% through meal planning and composting",
]

# ═══════════════════════════════════════════════════════════════════════════════
# CLASSE OFF_TOPIC -- Contenu sans rapport avec l'écologie
# ═══════════════════════════════════════════════════════════════════════════════

OFFTOPIC_FR = [
    "Terrible accident sur l'autoroute A1 ce matin, 3 blessés graves",
    "Résultats des élections municipales : la liste verte arrive en tête",
    "Quel match incroyable hier soir ! 3-0 en finale de coupe",
    "Il fait très beau aujourd'hui, parfait pour sortir",
    "J'ai mangé un excellent tajine au restaurant ce midi",
    "Embouteillages monstres sur le périphérique ce matin",
    "Le ministre de la santé annonce de nouvelles mesures",
    "Visite du musée d'art moderne hier, exposition magnifique",
    "Grève des transports en commun prévue demain matin",
    "Blessure grave du joueur star lors du match de championnat",
    "Film de l'année : la comédie cartonne au box-office",
    "Arrestation d'un suspect dans l'affaire du cambriolage",
    "Soldes d'hiver : -50% dans toutes les grandes enseignes",
    "Naissance du bébé royal, toute la nation se réjouit",
    "Hausse des prix du carburant : les automobilistes en colère",
    "Concert de rock annulé à la dernière minute, les fans déçus",
    "Championnat du monde de football : notre équipe en quarts",
    "Procès très médiatisé : le verdict attendu demain",
    "Météo : fortes pluies prévues ce week-end dans le nord",
    "Nouveau restaurant étoilé ouvert en centre-ville",
    "Décès d'une victime suite à un accident de la route",
    "Trois personnes hospitalisées après une collision frontale",
    "Vote de confiance au parlement ce soir, résultat incertain",
    "Attentat déjoué : les autorités démantèlent un réseau",
    "Série Netflix du moment : tout le monde en parle",
    "Promotion exceptionnelle : smartphone haut de gamme à -40%",
    "Scandale politique : le ministre démissionne",
    "Match retour ce soir, notre équipe doit marquer 2 buts",
    "Urgence médicale : l'hôpital en situation de saturation",
    "Cambriolage en plein centre-ville, la police enquête",
    "Grève générale annoncée pour le mois prochain",
    "Incident diplomatique entre les deux pays voisins",
    "Fermeture du magasin préféré, les clients nostalgiques",
    "Résultats du bac : taux de réussite record cette année",
    "Embauche record dans le secteur de la technologie",
    "Bouchon de 20 km sur l'autoroute suite à un accident grave",
    "Finale de la coupe du roi ce soir, ambiance électrique !",
    "Nouveau téléphone sorti aujourd'hui, les fans font la queue",
    "La bourse de Paris a chuté de 3% ce matin",
    "Le nouveau film d'action cartonne dans toutes les salles",
    "Mariage de la star avec son partenaire de longue date",
    "Tournoi de tennis : la finale sera épique ce dimanche",
    "Le gouvernement annonce un nouveau plan économique",
    "Sortie du dernier album du groupe de rock favori",
    "Reportage sur les inégalités salariales en France",
    "Nouveau vaccin approuvé par les autorités sanitaires",
    "Inauguration du nouveau centre commercial en banlieue",
    "L'équipe nationale qualifiée pour la coupe du monde 2026",
    "Manifestation des agriculteurs devant le parlement européen",
    "Crise diplomatique : ambassadeur convoqué au ministère",
    "L'inflation atteint 5% ce mois, le pouvoir d'achat recule",
    "Accident de train : le trafic perturbé sur la ligne nord",
    "Le chef étoilé présente son nouveau menu de saison",
    "Transfert du joueur vedette pour 100 millions d'euros",
    "Nouveau record du monde d'athlétisme battu à Paris",
    "Séisme de magnitude 5.2 ressenti dans le sud du pays",
    "Hausse record du chômage au dernier trimestre",
    "Le palais royale accueille une exposition temporaire",
    "Nouveau médicament contre le diabète approuvé en Europe",
    "Réforme des retraites : les syndicats appellent à la grève",
    "Arrestation d'un trafiquant de drogues à l'aéroport",
    "Le festival de cinéma couronne le film étranger",
    "Décès du chanteur légendaire à l'âge de 78 ans",
    "Ouverture du nouveau stade olympique, splendide architecture",
    "Prise d'otages déjouée par les forces spéciales",
    "Le prix Nobel de littérature attribué à un auteur africain",
    "Nouveau scandale financier implique une grande banque",
    "La population mondiale dépasse les 8 milliards d'habitants",
    "Tempête tropicale frappe les côtes, évacuations en cours",
    "Le gouvernement présente son budget pour l'année prochaine",
    "Sortie très attendue du prochain épisode de la saga",
    # ── Nouveaux off-topic v3 : textes neutres/ambigus ──
    "Belle journée aujourd'hui, j'ai fait un tour en voiture",
    "Ma nouvelle recette de gâteau au chocolat est incroyable",
    "Regardez cette photo magnifique que j'ai prise",
    "Qui veut jouer au foot ce soir au stade ?",
    "Le nouveau smartphone est sorti, les specs sont folles",
    "J'ai acheté une nouvelle robe pour la fête de ce soir",
    "Le coiffeur m'a fait une coupe incroyable aujourd'hui",
    "Mon chat est trop mignon sur cette photo",
    "Week-end barbecue avec les amis, c'était top",
    "Le dernier épisode de la série était dingue",
    "Bitcoin à 100k, qui l'aurait cru ?",
    "Nouvelle salle de sport ouverte dans le quartier",
    "Le prix de l'immobilier continue de monter",
    "J'ai gagné au loto, je n'y crois pas !",
    "Anniversaire surprise pour ma meilleure amie hier",
]

OFFTOPIC_AR = [
    "حادث سير خطير على الطريق السريع، إصابات عديدة",
    "نتائج الانتخابات البلدية أُعلنت البارحة",
    "مباراة نارية البارحة، فريقنا تأهّل للنهائي",
    "الطقس جميل اليوم في المدينة",
    "تناولت وجبة رائعة في المطعم الجديد",
    "اعتقال مشتبه به في قضية السرقة الكبرى",
    "وزير الصحة يُعلن عن إجراءات جديدة للوقاية",
    "ارتفاع أسعار الوقود يُقلق المواطنين",
    "فيلم جديد يُحقق أرقاماً قياسية في شباك التذاكر",
    "إضراب عمال المواصلات العامة غداً",
    "الاقتصاد الوطني يعاني من التضخم هذا العام",
    "منتخبنا يتأهل إلى كأس العالم بعد فوز تاريخي",
    "حادثة سير مروعة تودي بحياة شخصين على الطريق السريع",
    "البرلمان يصوت على قانون الميزانية الجديد",
    "اكتشاف أثري جديد في منطقة الحفريات الجنوبية",
    "انتخاب رئيس الجمهورية بنسبة 70% من الأصوات",
    "اجتماع قمة دولية لمناقشة الأزمة الاقتصادية",
    "مباراة السوبر كأس تجلب الملايين للمدرجات",
]

OFFTOPIC_EN = [
    "Terrible car accident on the highway this morning, 3 injured",
    "Election results announced: turnout was record-breaking",
    "Amazing football match last night, our team won the championship",
    "Beautiful weather today, perfect for a walk",
    "Had an amazing dinner at the new Italian restaurant",
    "Traffic chaos downtown after a serious accident",
    "New movie breaks box office records worldwide",
    "Stock market crash worries investors globally",
    "Celebrity wedding sparks media frenzy",
    "Police arrest suspects in major robbery case",
    "Hospital overwhelmed after multiple emergency admissions",
    "Political scandal forces minister to resign",
    "Black Friday deals: 70% off all electronics",
    "Sports star retires after 20-year career",
    "New TV series becomes instant streaming hit",
    "A major earthquake struck the coastal region early today",
    "The president signed the new economic reform bill into law",
    "Record attendance at the music festival this summer",
    "The latest smartphone model sold out within hours of launch",
    "A devastating flood left thousands homeless in the region",
    "The stock market hit an all-time high before the crash",
    "Global summit on trade negotiations yields no agreement",
    "The award-winning director releases long-awaited sequel",
    "Airport disruptions caused by the air traffic controller strike",
    # ── Nouveaux off-topic EN v3 ──
    "Just finished watching the best series ever, totally recommend it",
    "My new car handles amazingly on the highway",
    "Check out my new outfit for the party tonight",
    "Best pizza I've ever had at the new place downtown",
    "The championship finals were absolutely thrilling",
    "Got a new haircut today and I'm loving it",
    "Cryptocurrency market is booming again this week",
    "Wedding photos turned out beautiful, so happy",
    "The jury deliberated for three days before reaching a verdict",
    "Inflation hits a 40-year high in the country",
    "The boxing champion defends his title in a spectacular fight",
    "Cybersecurity breach exposes millions of user accounts",
    "The tech giant announces massive layoffs worldwide",
    "Historic peace deal signed between the two rival nations",
]

# ═══════════════════════════════════════════════════════════════════════════════
# CLASSE TOXIC -- Insultes, anti-environnement, haine
# ═══════════════════════════════════════════════════════════════════════════════

TOXIC_FR = [
    "Cette application est nulle, quelle arnaque de merde",
    "Je m'en fous de la nature, jeter par terre c'est plus simple",
    "Vous êtes tous des connards avec votre écologie de merde",
    "La planète peut crever, j'en ai rien à foutre",
    "Nique ta mère et ton recyclage inutile",
    "Les écolos sont des imbéciles qui vivent dans leur monde",
    "Brûler les forêts c'est notre droit, pas besoin d'autorisation",
    "L'écologie c'est une arnaque inventée pour nous taxer",
    "Putain de merde cette appli bug encore, vous êtes nuls",
    "Jeter les déchets dans la rivière, qui va regarder de toute façon",
    "Tuer les animaux sauvages c'est normal, arrêtez de pleurnicher",
    "Le réchauffement climatique c'est du fake, réveillez-vous",
    "Vous êtes des crétin avec vos éoliennes merdiques",
    "Chasse illégale ? Et alors, c'est ma liberté !",
    "Imbéciles d'écolos qui voulez ruiner l'économie",
    "Jeter le plastique dans la mer, la nature s'en remet toujours",
    "Ta gueule avec tes leçons de tri sélectif",
    "Ces militants écolo sont des malades mentaux",
    "Déverser les huiles usées dans le sol, personne ne le saura",
    "Abattre les arbres pour construire c'est le progrès, deal with it",
    "Vous nous faites chier avec vos conneries vertes",
    "Je vais jeter mes déchets chimiques dans le lac ce soir",
    "Braconnage ? C'est du sport pour nous, lâchez-nous",
    "Merde à vos panneaux solaires et votre survivalisme bobo",
    "Dépôt sauvage dans la forêt, et alors ? Personne ne m'a vu",
    "Je déteste les écolos hypocrites qui prennent l'avion",
    "Pollution ? J'ai payé mes impôts, laissez-moi tranquille",
    "Ces associations écolo ne servent qu'à récolter des sous",
    "Crever avec votre planète verte, moi je fais ma vie",
    "Vidange sauvage dans le fossé, c'est plus pratique",
    "Les animaux sont là pour être mangés, arrêtez votre cirque",
    "Le plastique dans l'océan ? C'est pas mon problème",
    "Je brûle mes ordures dans le jardin, problème ?",
    "Vos arbres je les couperai pour faire ma terrasse, bande de nuls",
    "Ferme-la avec ton tri sélectif inutile, c'est tout mélangé de toute façon",
    # ── Nouveaux toxic FR v3 ──
    "L'écologie c'est ridicule, moi je pollue comme je veux",
    "Bande d'abrutis avec vos poubelles de tri, tout finit au même endroit",
    "Je jette mes piles dans la rivière, et alors ?",
    "Les écolos sont des parasites de la société",
    "J'ai versé de l'huile de vidange dans le fossé, c'est plus rapide",
    "Vos panneaux solaires c'est de la merde qui sert à rien",
    "La nature c'est nul, moi je préfère le béton",
    "Arrêtez de nous emmerder avec vos recyclages à la con",
]

TOXIC_AR = [
    "هذا التطبيق تافه ويضيع وقتنا",
    "ما أبالي بالبيئة، الأهم هو المال",
    "كلكم حمقى بحديثكم عن البيئة",
    "رمي النفايات في الشارع أسهل وفقط",
    "الصيد غير القانوني حقّنا ولا أحد يمنعنا",
    "اقطع الأشجار وابنِ، هذا هو التطور",
    "لا أكترث للطبيعة، اتركوني في حالي",
    "البيئة عذرة لأخذ أموالنا في الضرائب",
    "حرق الغابات لتوسيع الأراضي أمر مشروع",
    "هؤلاء النشطاء البيئيون مجانين ومتعصبون",
    "ألقِ النفايات أينما أردت، الطبيعة ستتعافى",
    "الصيد الجائر ممارسة ترفيهية لا جريمة",
    "النفايات الكيميائية في النهر؟ لن يعرف أحد",
    "تعبت من هؤلاء المدافعين عن البيئة المتعصبين",
    "المناخ لم يتغير، كل هذا أكاذيب الغرب",
]

TOXIC_EN = [
    "This app is crap, total waste of time and money",
    "Who cares about nature, I'll throw garbage wherever I want",
    "You're all idiots with your recycling nonsense",
    "Screw environmentalists and their useless protests",
    "Climate change is a lie invented by elites to control us",
    "I'll dump chemicals anywhere I want, no one can stop me",
    "Kill all the wolves, they're just a pest anyway",
    "What a stupid app, you f***ing idiots",
    "Illegal logging is business, stop your whining eco-freaks",
    "Hate this platform and everyone on it",
    "Environmental regulations are destroying the economy, idiots",
    "Burn it all down, I don't care about trees",
    "Poaching is a tradition, you tree-huggers can go to hell",
    "Dump industrial waste in the river, no one will know",
    "I throw my trash anywhere I want, deal with it",
    "These green activists should be jailed, not celebrated",
    "Global warming is a scam pushed by corrupt scientists",
    "I run my diesel car double shifts just to annoy the greens",
    "Eco-terrorists blocking progress with their stupid protests",
    "I intentionally burn plastic waste in my yard every day",
    "Nature is just a resource to exploit, stop the sentimentalism",
    "Your solar panels are ugly and useless, rip them all down",
    "I illegally dump oil in the ground regularly, so what",
    "Conservation areas are a waste of land that could be farmed",
    # ── Nouveaux toxic EN v3 ──
    "Recycling is a scam, everything ends up in the same landfill",
    "Who cares about the planet, we'll be dead before it matters",
    "I throw my batteries in the trash, nobody checks anyway",
    "Environmental regulations are killing small businesses",
    "Shut up about climate change, it's all politics",
    "I poured chemicals down the drain, what are you gonna do about it",
    "These tree-huggers should get real jobs instead of protesting",
    "Deforestation creates jobs, stop crying about trees",
    "These environmentalists are mentally ill cult members",
]

# ═══════════════════════════════════════════════════════════════════════════════
# ASSEMBLAGE ET AUGMENTATION DU DATASET
# ═══════════════════════════════════════════════════════════════════════════════

def augment(texts: list, n: int) -> list:
    """
    Augmente la liste par rééchantillonnage aléatoire avec de légères
    variations pour atteindre n exemples.
    """
    out = list(texts)
    emojis_eco    = ["[*]", "♻️", "🌍", "🌿", "🌊", "🌳", "☀️", "💚", "🐝", "🦋"]
    emojis_offtop = ["⚽", "🏆", "📰", "🎬", "🎵", "💰", "🏥", "🚗", "🗳️", "📱"]
    emojis_toxic  = ["😡", "🤬", "💢", "🖕", "☠️"]

    def _get_emojis(text):
        t = text.lower()
        if any(w in t for w in ["recyclage", "arbre", "ecologie", "nature", "plage", "solar", "compost", "eco", "beach", "tree"]):
            return emojis_eco
        if any(w in t for w in ["merde", "connard", "idiot", "stupid", "hate", "crap", "dump", "burn", "kill"]):
            return emojis_toxic
        return emojis_offtop

    while len(out) < n:
        t = random.choice(texts)
        emojis = _get_emojis(t)
        variations = [
            t,
            t.capitalize(),
            t + " !",
            t.replace(",", " ;"),
            random.choice(emojis) + " " + t,
            t + " " + random.choice(emojis),
            t.upper()[:20] + t[20:],
            t + ".",
            t.replace(".", "..."),
            "👉 " + t,
        ]
        out.append(random.choice(variations))
    return out[:n]


def build_dataset(path: str = OUT, n_per_class: int = 4000):
    """
    Construit le CSV d'entraînement avec n_per_class exemples par classe.
    Total : 3 × n_per_class = 9 000 exemples par défaut.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)

    all_eco = (
        ECO_FR + ECO_AR + ECO_EN
        + ECO_GREETINGS_FR + ECO_GREETINGS_AR + ECO_GREETINGS_EN
        + ECO_POLLUTION_DOC_FR + ECO_POLLUTION_DOC_AR + ECO_POLLUTION_DOC_EN
    )
    # Use enriched 10-category off_topic data if available
    if _OFFTOPIC_ENRICHED:
        all_offtopic = _OT_FR + _OT_AR + _OT_EN + OFFTOPIC_FR + OFFTOPIC_AR + OFFTOPIC_EN
    else:
        all_offtopic = OFFTOPIC_FR + OFFTOPIC_AR + OFFTOPIC_EN
    all_toxic = TOXIC_FR + TOXIC_AR + TOXIC_EN

    eco_rows      = [(t, "eco")       for t in augment(all_eco,      n_per_class)]
    offtopic_rows = [(t, "off_topic") for t in augment(all_offtopic, n_per_class)]
    toxic_rows    = [(t, "toxic")     for t in augment(all_toxic,     n_per_class)]

    rows = eco_rows + offtopic_rows + toxic_rows
    random.shuffle(rows)

    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["text", "label"])
        writer.writerows(rows)

    print(f"[OK] Dataset généré : {len(rows)} exemples → {path}")
    print(f"   eco={len(eco_rows)} | off_topic={len(offtopic_rows)} | toxic={len(toxic_rows)}")


if __name__ == "__main__":
    build_dataset()
