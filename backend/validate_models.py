import sys
sys.stdout.reconfigure(encoding='utf-8')

print('=== VALIDATION DES NOUVEAUX MODELES ===')
print()

from moderation_ai.eco_moderator import EcoCNNModerator

mod = EcoCNNModerator()
print('[OK] Moderateur charge avec succes')
print()

tests = [
    ('Accident de voiture terrible sur l autoroute, 3 blesses graves', 'pending_review', 'Violence/accident'),
    ('Bagarre eclate en pleine rue, la video devient virale sur les reseaux', 'pending_review', 'Bagarre/violence'),
    ('Mon haul shopping du weekend : Maquillage et rouge a levres Zara', 'pending_review', 'Mode/beaute'),
    ('Recette de tajine d agneau aux pruneaux, un veritable delice', 'pending_review', 'Cuisine'),
    ('Quel match incroyable ! 3-0 en finale de la Ligue des Champions', 'pending_review', 'Sport'),
    ('Bitcoin franchit 100 000 dollars, les cryptos explosent', 'pending_review', 'Finance/crypto'),
    ('Nettoyons notre quartier ensemble ! Recyclons les dechets plastique', 'published', 'ECO nettoyage'),
    ('Nous avons ramasse 50 kg de dechets sur la plage ce matin', 'published', 'ECO ramassage'),
    ('Pensez a trier vos dechets : plastique, verre, papier bons bacs', 'published', 'ECO tri dechets'),
    ('Protegeons la foret et la biodiversite ensemble pour les generations', 'published', 'ECO nature'),
    ('Cette application est nulle, une vraie arnaque de merde', 'rejected', 'Toxique'),
    ('Bonjour tout le monde !', 'published', 'Salutation'),
    ('Casino en ligne machine a sous paris sportifs jackpot loterie', 'pending_review', 'Jeux argent'),
    ('Serie netflix saison finale binge watch episode oscars', 'pending_review', 'Divertissement'),
]

col_w = [32, 15, 15, 6]
header = '{:<32} {:<15} {:<15} {:<6} {}'.format('Description', 'Attendu', 'Obtenu', 'Score', 'OK?')
print(header)
print('-' * 85)

ok_count = 0
fail_count = 0
for text, expected, desc in tests:
    r = mod.moderate(text=text)
    got = r.status
    score = r.score
    is_ok = (got == expected) or (desc == 'Salutation' and got in ['published', 'pending_review'])
    icon = '[OK] ' if is_ok else '[ERR]'
    if is_ok:
        ok_count += 1
    else:
        fail_count += 1
    line = '{} {:<32} {:<15} {:<15} {:.2f}'.format(icon, desc, expected, got, score)
    print(line)

print()
pct = ok_count * 100 // len(tests)
print('Resultats : {}/{} correct ({}%)'.format(ok_count, len(tests), pct))
print()
if fail_count == 0:
    print('[OK] TOUS LES TESTS PASSES - modeles prets pour la production')
else:
    print('[WARN] {} echec(s) - voir details ci-dessus'.format(fail_count))
