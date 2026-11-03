import sys
sys.stdout.reconfigure(encoding='utf-8')

print('=== TEST SPECIFIQUE : images sans texte ===')
print()

from moderation_ai.eco_moderator import EcoCNNModerator

mod = EcoCNNModerator(rules_only=True)  # test regles uniquement (sans charger les gros modeles)

tests = [
    # (text, image_path, attendu, description)
    ('', None, 'pending_review', 'Image seule SANS texte => doit etre pending'),
    ('  ', None, 'pending_review', 'Texte vide (espaces) => doit etre pending'),
    ('ok', None, 'pending_review', 'Texte 2 chars => doit etre pending'),
    ('Nettoyons notre quartier et recyclons les dechets plastique', None, 'published', 'Texte eco = doit publier'),
    ('Bonjour tout le monde !', None, 'published', 'Salutation = doit publier'),
    ('Accident de voiture terrible 3 blesses graves', None, 'pending_review', 'Violence = doit etre pending'),
    ('Bitcoin crypto trading bourse chute ethereum nft', None, 'pending_review', 'Crypto = doit etre pending'),
    ('Maquillage rouge a levres haul shopping fashion week', None, 'pending_review', 'Mode = doit etre pending'),
]

ok_count = 0
for text, img, expected, desc in tests:
    r = mod.moderate(text=text, image_local_path=img or '')
    got = r.status
    is_ok = got == expected
    icon = '[OK]' if is_ok else '[ERR]'
    if is_ok:
        ok_count += 1
    print('{} {:<48} => {} (attendu: {})'.format(icon, desc, got, expected))
    if r.reasons:
        print('     Raison: {}'.format(r.reasons[0][:80]))

print()
print('Resultats : {}/{} ({}%)'.format(ok_count, len(tests), ok_count*100//len(tests)))
