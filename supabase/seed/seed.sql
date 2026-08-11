-- ============================================================================
-- Green Park Family Restaurant - Seed Data
-- Realistic demo content for development / first launch
-- ============================================================================

-- Public storage URL base
\set url 'https://tygwlqvtxhepngwnnpqu.supabase.co/storage/v1/object/public'

-- Register the restaurant owner as admin
insert into public.admins (id, email, full_name)
values (
  'e1371f89-b84c-4a29-a9f1-fdf318754b8a',
  'dwarampudisriramreddy@gmail.com',
  'Dwarampudisri Ramreddy'
) on conflict (id) do nothing;

-- Set logo + hero on restaurant profile
update public.restaurant_info
set logo_url = :'url' || '/restaurant-images/logo.png',
    hero_image_url = :'url' || '/restaurant-images/hero.jpg';

-- ----------------------------------------------------------------------------
-- Categories
-- ----------------------------------------------------------------------------
insert into public.categories (name, description, icon, sort_order) values
  ('Starters',          'Crispy bites and flame-kissed appetisers to begin your meal.',   'tapas',   1),
  ('Soups',             'Warm, comforting soups made fresh every day.',                   'soup',    2),
  ('Biryanis',          'Slow-cooked dum biryanis - our signature pride.',                'rice',    3),
  ('Rice & Noodles',    'Wholesome fried rice and noodle classics.',                      'ramen',   4),
  ('Curries',           'Rich Andhra gravies and homestyle curries.',                     'curry',   5),
  ('Tandoori',          'Wood-fired kebabs, tikkas and fresh breads.',                    'grill',   6),
  ('Chinese',           'Indo-Chinese favourites with an Andhra twist.',                  'chinese', 7),
  ('Vegetarian',        'A dedicated selection for our vegetarian guests.',               'veg',     8),
  ('Non-Vegetarian',    'Andhra-style chicken, mutton and coastal specialities.',         'nonveg',  9),
  ('Desserts',          'Sweet endings to complete your meal.',                           'dessert', 10),
  ('Beverages',         'Cooling drinks, lassis and refreshing mocktails.',               'cafe',    11)
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- Menu items
-- ----------------------------------------------------------------------------
insert into public.menu_items
  (category_id, name, description, price, image_url, is_veg, is_spicy, is_bestseller, is_available, is_active, sort_order)
values
  -- Starters -------------------------------------------------------------
  ((select id from public.categories where name='Starters'), 'Chicken 65',
   'Golden-fried Andhra-style chicken tossed with curry leaves, ginger and green chillies.',
   240.00, :'url' || '/menu-images/chicken-65.jpg', false, true, true, true, true, 1),
  ((select id from public.categories where name='Starters'), 'Chilli Chicken',
   'Juicy chicken bites stir-fried with bell peppers, onions and a sweet-spicy chilli glaze.',
   250.00, :'url' || '/menu-images/chilli-chicken.jpg', false, true, false, true, true, 2),
  ((select id from public.categories where name='Starters'), 'Paneer 65',
   'Crispy paneer cubes in a fiery Andhra masala with curry leaves.',
   210.00, :'url' || '/menu-images/paneer.jpg', true, true, false, true, true, 3),
  ((select id from public.categories where name='Starters'), 'Gobi Manchurian',
   'Cauliflower florets in a tangy Indo-Chinese Manchurian sauce.',
   180.00, :'url' || '/menu-images/gobi.jpg', true, true, false, true, true, 4),
  ((select id from public.categories where name='Starters'), 'Veg Manchurian',
   'Mixed vegetable balls tossed with garlic, chilli and spring onions.',
   170.00, :'url' || '/menu-images/chinese.jpg', true, true, false, true, true, 5),
  ((select id from public.categories where name='Starters'), 'Crispy Corn',
   'Golden fried sweet corn seasoned with pepper and chaat masala.',
   190.00, :'url' || '/menu-images/salad.jpg', true, false, false, true, true, 6),
  ((select id from public.categories where name='Starters'), 'Chicken Lollipop',
   'Marinated winglets fried golden and served with a spicy schezwan dip.',
   260.00, :'url' || '/menu-images/lollipop.jpg', false, true, false, true, true, 7),
  ((select id from public.categories where name='Starters'), 'Tandoori Chicken (Half)',
   'Overnight spiced chicken roasted in our wood-fired tandoor.',
   320.00, :'url' || '/menu-images/tandoori.jpg', false, true, true, true, true, 8),
  ((select id from public.categories where name='Starters'), 'Pepper Chicken Dry',
   'Coarse-cracked pepper roasted chicken - an East Godavari favourite.',
   270.00, null, false, true, false, true, true, 9),
  -- Soups ----------------------------------------------------------------
  ((select id from public.categories where name='Soups'), 'Hot & Sour Veg Soup',
   'The classic Indo-Chinese soup - hot, sour and satisfying.',
   120.00, :'url' || '/menu-images/soup.jpg', true, true, false, true, true, 1),
  ((select id from public.categories where name='Soups'), 'Sweet Corn Veg Soup',
   'Silky corn soup with crunchy vegetables and a pepper finish.',
   130.00, null, true, false, false, true, true, 2),
  ((select id from public.categories where name='Soups'), 'Chicken Clear Soup',
   'Slow-simmered chicken broth with shredded chicken and herbs.',
   140.00, null, false, false, false, true, true, 3),
  ((select id from public.categories where name='Soups'), 'Mutton Soup',
   'Rich, bone-simmered mutton broth with ginger and pepper.',
   180.00, null, false, true, false, true, true, 4),
  ((select id from public.categories where name='Soups'), 'Lemon Coriander Soup',
   'Light and fragrant soup with lemon and fresh coriander.',
   120.00, null, true, false, false, true, true, 5),
  -- Biryanis ---------------------------------------------------------------
  ((select id from public.categories where name='Biryanis'), 'Chicken Dum Biryani',
   'Fragrant basmati layered with spiced chicken, sealed and slow-cooked on dum.',
   280.00, :'url' || '/menu-images/biryani.jpg', false, true, true, true, true, 1),
  ((select id from public.categories where name='Biryanis'), 'Mutton Dum Biryani',
   'Tender mutton on bone with saffron basmati - a connoisseur''s pick.',
   380.00, :'url' || '/menu-images/biryani-mutton.jpg', false, true, true, true, true, 2),
  ((select id from public.categories where name='Biryanis'), 'Special Green Park Biryani',
   'Our signature - double chicken, egg, extra masala and a secret blend of spices.',
   320.00, :'url' || '/menu-images/biryani.jpg', false, true, true, true, true, 3),
  ((select id from public.categories where name='Biryanis'), 'Veg Dum Biryani',
   'Seasonal vegetables and paneer dum-cooked with saffron basmati.',
   220.00, :'url' || '/menu-images/biryani-veg.jpg', true, false, false, true, true, 4),
  ((select id from public.categories where name='Biryanis'), 'Egg Biryani',
   'Spicy masala rice with boiled eggs, curry leaves and onion raita.',
   220.00, null, true, true, false, true, true, 5),
  ((select id from public.categories where name='Biryanis'), 'Prawn Biryani',
   'Coastal favourite - prawns tossed in masala and layered on fragrant rice.',
   350.00, :'url' || '/menu-images/prawns.jpg', false, true, false, true, true, 6),
  ((select id from public.categories where name='Biryanis'), 'Fish Biryani',
   'Boneless fish marinated in spicy gravy, layered with basmati and herbs.',
   330.00, :'url' || '/menu-images/fish.jpg', false, true, false, true, true, 7),
  -- Rice & Noodles ----------------------------------------------------------
  ((select id from public.categories where name='Rice & Noodles'), 'Chicken Fried Rice',
   'Wok-tossed rice with chicken, egg, spring onion and soy.',
   220.00, :'url' || '/menu-images/fried-rice.jpg', false, false, false, true, true, 1),
  ((select id from public.categories where name='Rice & Noodles'), 'Veg Fried Rice',
   'Garden vegetables tossed with smoky, wok-fried rice.',
   180.00, null, true, false, false, true, true, 2),
  ((select id from public.categories where name='Rice & Noodles'), 'Egg Fried Rice',
   'Classic egg fried rice with green chillies and spring onions.',
   200.00, null, true, false, false, true, true, 3),
  ((select id from public.categories where name='Rice & Noodles'), 'Schezwan Chicken Fried Rice',
   'Fiery schezwan sauce wok-fried with chicken and veggies.',
   250.00, null, false, true, false, true, true, 4),
  ((select id from public.categories where name='Rice & Noodles'), 'Veg Noodles',
   'Hakka noodles tossed with crunchy vegetables.',
   170.00, :'url' || '/menu-images/noodles.jpg', true, false, false, true, true, 5),
  ((select id from public.categories where name='Rice & Noodles'), 'Chicken Noodles',
   'Stir-fried noodles with chicken, cabbage, carrot and soy.',
   220.00, null, false, false, false, true, true, 6),
  ((select id from public.categories where name='Rice & Noodles'), 'Schezwan Noodles',
   'Spicy schezwan noodles with vegetables and sesame.',
   240.00, null, true, true, false, true, true, 7),
  ((select id from public.categories where name='Rice & Noodles'), 'Mushroom Fried Rice',
   'Umami-packed fried rice with button mushrooms and pepper.',
   220.00, null, true, false, false, true, true, 8),
  -- Curries --------------------------------------------------------------
  ((select id from public.categories where name='Curries'), 'Andhra Chicken Curry',
   'The quintessential Kura - country chicken simmered in a fiery ground masala.',
   260.00, :'url' || '/menu-images/curry-chicken.jpg', false, true, true, true, true, 1),
  ((select id from public.categories where name='Curries'), 'Mutton Curry',
   'Slow-cooked mutton in a rich, dark Andhra onion masala.',
   360.00, :'url' || '/menu-images/mutton.jpg', false, true, false, true, true, 2),
  ((select id from public.categories where name='Curries'), 'Prawn Curry (Royyala Pulusu)',
   'Coastal prawn curry with tamarind, coconut and fiery chillies.',
   340.00, :'url' || '/menu-images/prawns.jpg', false, true, false, true, true, 3),
  ((select id from public.categories where name='Curries'), 'Butter Chicken',
   'Creamy, mildly sweet tomato-butter gravy with grilled chicken.',
   320.00, null, false, false, false, true, true, 4),
  ((select id from public.categories where name='Curries'), 'Palak Paneer',
   'Fresh spinach puree with soft paneer cubes and garlic tempering.',
   230.00, :'url' || '/menu-images/paneer.jpg', true, false, false, true, true, 5),
  ((select id from public.categories where name='Curries'), 'Paneer Butter Masala',
   'Silky makhani gravy with tandoor-roasted paneer.',
   240.00, null, true, false, false, true, true, 6),
  ((select id from public.categories where name='Curries'), 'Dal Tadka',
   'Yellow lentils tempered with ghee, garlic and red chillies.',
   150.00, null, true, false, false, true, true, 7),
  ((select id from public.categories where name='Curries'), 'Gongura Chicken',
   'Country chicken cooked with tangy sorrel leaves - a Godavari delicacy.',
   280.00, null, false, true, false, true, true, 8),
  ((select id from public.categories where name='Curries'), 'Chepala Pulusu (Fish Curry)',
   'River fish in a traditional tamarind-and-red-chilli gravy.',
   300.00, :'url' || '/menu-images/fish.jpg', false, true, false, true, true, 9),
  ((select id from public.categories where name='Curries'), 'Veg Kurma',
   'Mixed vegetables in a mild, aromatic coconut-cashew gravy.',
   200.00, :'url' || '/menu-images/veg-curry.jpg', true, false, false, true, true, 10),
  ((select id from public.categories where name='Curries'), 'Kadai Mushroom',
   'Mushroom and capsicum in a coarse kadai masala.',
   220.00, null, true, true, false, true, true, 11),
  -- Tandoori ---------------------------------------------------------------
  ((select id from public.categories where name='Tandoori'), 'Tandoori Chicken (Full)',
   'Whole spring chicken marinated in yogurt and tandoori spices.',
   520.00, :'url' || '/menu-images/tandoori.jpg', false, true, true, true, true, 1),
  ((select id from public.categories where name='Tandoori'), 'Chicken Tikka',
   'Char-grilled chicken chunks with mint chutney and onion rings.',
   300.00, :'url' || '/menu-images/tikka.jpg', false, true, false, true, true, 2),
  ((select id from public.categories where name='Tandoori'), 'Paneer Tikka',
   'Smoky tandoor-roasted paneer with peppers and chaat masala.',
   250.00, :'url' || '/menu-images/paneer.jpg', true, true, false, true, true, 3),
  ((select id from public.categories where name='Tandoori'), 'Malai Chaap',
   'Creamy, mild soya chaap grilled to a golden finish.',
   230.00, null, true, false, false, true, true, 4),
  ((select id from public.categories where name='Tandoori'), 'Tandoori Roti',
   'Whole-wheat bread baked in the tandoor.',
   30.00, null, true, false, false, true, true, 5),
  ((select id from public.categories where name='Tandoori'), 'Butter Naan',
   'Soft leavened bread brushed with butter.',
   45.00, :'url' || '/menu-images/naan.jpg', true, false, false, true, true, 6),
  ((select id from public.categories where name='Tandoori'), 'Garlic Naan',
   'Naan topped with minced garlic, coriander and butter.',
   50.00, null, true, false, false, true, true, 7),
  -- Chinese ---------------------------------------------------------------
  ((select id from public.categories where name='Chinese'), 'Gobi 65',
   'Crispy cauliflower with curry leaves, yoghurt and chilli.',
   190.00, :'url' || '/menu-images/gobi.jpg', true, true, false, true, true, 1),
  ((select id from public.categories where name='Chinese'), 'Chilli Paneer',
   'Crispy paneer tossed in a glossy, fiery chilli-garlic sauce.',
   240.00, :'url' || '/menu-images/paneer.jpg', true, true, false, true, true, 2),
  ((select id from public.categories where name='Chinese'), 'Spring Rolls',
   'Crispy rolls stuffed with vegetables and served with sweet chilli dip.',
   160.00, :'url' || '/menu-images/chinese.jpg', true, false, false, true, true, 3),
  ((select id from public.categories where name='Chinese'), 'Chicken Manchurian',
   'Crispy chicken balls in a tangy Manchurian sauce.',
   250.00, :'url' || '/menu-images/chilli-chicken.jpg', false, true, false, true, true, 4),
  ((select id from public.categories where name='Chinese'), 'Prawn Fried Rice',
   'Wok-tossed rice with plump prawns, egg and spring onion.',
   320.00, :'url' || '/menu-images/prawns.jpg', false, false, false, true, true, 5),
  ((select id from public.categories where name='Chinese'), 'Schezwan Chicken Noodles',
   'Spicy schezwan noodles loaded with chicken strips.',
   260.00, :'url' || '/menu-images/noodles.jpg', false, true, false, true, true, 6),
  ((select id from public.categories where name='Chinese'), 'Dragon Chicken',
   'Semi-dry spicy chicken with peppers and sesame - a crowd favourite.',
   290.00, null, false, true, false, true, true, 7),
  -- Vegetarian -------------------------------------------------------------
  ((select id from public.categories where name='Vegetarian'), 'Paneer Tikka Masala',
   'Char-grilled paneer simmered in a rich tomato-onion gravy.',
   250.00, :'url' || '/menu-images/paneer.jpg', true, true, false, true, true, 1),
  ((select id from public.categories where name='Vegetarian'), 'Mushroom Curry',
   'Button mushrooms in a creamy, spiced onion-tomato gravy.',
   220.00, null, true, false, false, true, true, 2),
  ((select id from public.categories where name='Vegetarian'), 'Veg Kadai',
   'Colourful vegetables in a robust kadai masala.',
   230.00, null, true, true, false, true, true, 3),
  ((select id from public.categories where name='Vegetarian'), 'Baingan Bharta',
   'Smoky roasted eggplant mash tempered with garlic and green chillies.',
   200.00, null, true, false, false, true, true, 4),
  ((select id from public.categories where name='Vegetarian'), 'Curd Rice',
   'Comforting rice with yoghurt, tempered with mustard and curry leaves.',
   120.00, null, true, false, false, true, true, 5),
  ((select id from public.categories where name='Vegetarian'), 'Tomato Rice',
   'Tangy Andhra-style tomato rice with peanuts and spices.',
   150.00, null, true, false, false, true, true, 6),
  ((select id from public.categories where name='Vegetarian'), 'Paneer Fried Rice',
   'Smoky fried rice with paneer chunks and vegetables.',
   210.00, :'url' || '/menu-images/fried-rice.jpg', true, false, false, true, true, 7),
  -- Non-Vegetarian -----------------------------------------------------------
  ((select id from public.categories where name='Non-Vegetarian'), 'Andhra Chicken Fry',
   'Double-fried country chicken with ginger, garlic and fiery spices.',
   250.00, :'url' || '/menu-images/chicken-65.jpg', false, true, true, true, true, 1),
  ((select id from public.categories where name='Non-Vegetarian'), 'Pepper Chicken',
   'Stir-fried chicken with whole cracked pepper and curry leaves.',
   270.00, null, false, true, false, true, true, 2),
  ((select id from public.categories where name='Non-Vegetarian'), 'Mutton Fry',
   'Slow-cooked mutton dry roast with onions and red chilli paste.',
   380.00, :'url' || '/menu-images/mutton.jpg', false, true, false, true, true, 3),
  ((select id from public.categories where name='Non-Vegetarian'), 'Apollo Fish Fry',
   'Boneless fish marinated in a spicy-sour mix and deep fried.',
   320.00, :'url' || '/menu-images/fish.jpg', false, true, false, true, true, 4),
  ((select id from public.categories where name='Non-Vegetarian'), 'Chicken Pakodi',
   'Chicken fritters in a crunchy gram-flour batter.',
   220.00, :'url' || '/menu-images/chilli-chicken.jpg', false, true, false, true, true, 5),
  ((select id from public.categories where name='Non-Vegetarian'), 'Egg Curry',
   'Boiled eggs in a rich, spiced onion-tomato gravy.',
   180.00, null, false, true, false, true, true, 6),
  ((select id from public.categories where name='Non-Vegetarian'), 'Gongura Mutton',
   'Mutton simmered with sorrel leaves - an East Godavari signature.',
   400.00, null, false, true, false, true, true, 7),
  -- Desserts ---------------------------------------------------------------
  ((select id from public.categories where name='Desserts'), 'Gulab Jamun (2 pcs)',
   'Warm, syrupy dumplings with a hint of cardamom.',
   80.00, :'url' || '/menu-images/gulab-jamun.jpg', true, false, false, true, true, 1),
  ((select id from public.categories where name='Desserts'), 'Double Ka Meetha',
   'Classic Hyderabadi bread pudding with saffron and nuts.',
   120.00, :'url' || '/menu-images/dessert.jpg', true, false, false, true, true, 2),
  ((select id from public.categories where name='Desserts'), 'Ice Cream (1 Scoop)',
   'Vanilla, chocolate or strawberry - choose your flavour.',
   90.00, :'url' || '/menu-images/icecream.jpg', true, false, false, true, true, 3),
  ((select id from public.categories where name='Desserts'), 'Fruit Salad with Ice Cream',
   'Fresh seasonal fruits topped with a scoop of ice cream.',
   130.00, null, true, false, false, true, true, 4),
  ((select id from public.categories where name='Desserts'), 'Carrot Halwa',
   'Slow-cooked gajar ka halwa with ghee and dry fruits.',
   110.00, null, true, false, false, true, true, 5),
  ((select id from public.categories where name='Desserts'), 'Brownie with Ice Cream',
   'Warm chocolate brownie crowned with vanilla ice cream.',
   140.00, :'url' || '/menu-images/dessert.jpg', true, false, false, true, true, 6),
  -- Beverages ---------------------------------------------------------------
  ((select id from public.categories where name='Beverages'), 'Sweet Lassi',
   'Thick, creamy churned yoghurt drink - cool and refreshing.',
   90.00, :'url' || '/menu-images/lassi.jpg', true, false, false, true, true, 1),
  ((select id from public.categories where name='Beverages'), 'Salted Lassi',
   'Traditional salted lassi with a roasted cumin finish.',
   90.00, null, true, false, false, true, true, 2),
  ((select id from public.categories where name='Beverages'), 'Fresh Lime Soda',
   'Fresh lime with your choice of soda, salt or sugar.',
   70.00, :'url' || '/menu-images/drinks.jpg', true, false, false, true, true, 3),
  ((select id from public.categories where name='Beverages'), 'Masala Chaas',
   'Spiced buttermilk with coriander, ginger and green chilli.',
   60.00, null, true, false, false, true, true, 4),
  ((select id from public.categories where name='Beverages'), 'Filter Coffee',
   'Strong South Indian filter coffee with frothy milk.',
   50.00, :'url' || '/menu-images/coffee.jpg', true, false, false, true, true, 5),
  ((select id from public.categories where name='Beverages'), 'Thums Up / Coca-Cola (300ml)',
   'Ice-cold bottled soft drink.',
   40.00, null, true, false, false, true, true, 6),
  ((select id from public.categories where name='Beverages'), 'Mineral Water (1L)',
   'Chilled packaged drinking water.',
   20.00, null, true, false, false, true, true, 7),
  ((select id from public.categories where name='Beverages'), 'Green Park Special Mocktail',
   'A house special of fruits, mint and soda - the drink of the season.',
   140.00, :'url' || '/menu-images/juice.jpg', true, false, false, true, true, 8)
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- Offers
-- ----------------------------------------------------------------------------
insert into public.offers
  (title, description, banner_url, valid_from, valid_until, terms, is_featured, is_active)
values
  ('Sunday Biryani Special',
   'Flat 20% off on all dum biryanis every Sunday. Come hungry!',
   :'url' || '/offer-banners/offer-biryani.jpg', '2026-01-01', '2026-12-31',
   E'• Valid every Sunday from 11 AM to 11 PM.\n• Applicable on Chicken, Mutton and Special Green Park biryanis.\n• Cannot be clubbed with any other offer.\n• Not valid for party bookings.',
   true, true),
  ('Family Feast Combo',
   'Any 2 biryanis + 2 starters + 2 desserts for just ₹999. Perfect for 4.',
   :'url' || '/offer-banners/offer-family.jpg', '2026-07-01', '2026-09-30',
   E'• Serves 4 persons.\n• Choose from any biryani, starter and dessert on the menu.\n• Taxes as applicable.\n• Valid for dine-in only.',
   true, true),
  ('Student Special',
   '15% off on weekdays between 2 PM and 5 PM for all students. Just show your ID.',
   :'url' || '/offer-banners/offer-student.jpg', '2026-06-01', '2026-12-31',
   E'• Valid Monday to Friday, 2 PM - 5 PM.\n• Valid student ID required.\n• Valid on the total bill.\n• Not valid on beverages and bottled water.',
   false, true),
  ('Party & Celebration Offer',
   'Planning a celebration? Flat 25% off on bookings for groups of 10 or more.',
   :'url' || '/offer-banners/offer-party.jpg', '2026-01-01', '2026-12-31',
   E'• Minimum 10 guests.\n• Advance booking required.\n• Customised menu available on request.\n• Decoration arrangements available at extra cost.',
   true, true),
  ('Green Park Club Membership',
   'Join the Green Park Club and enjoy 10% off on every visit, all year round.',
   :'url' || '/offer-banners/offer-membership.jpg', '2026-01-01', '2026-12-31',
   E'• One-time membership fee of ₹299.\n• 10% off on every food bill.\n• Priority seating for members.\n• Membership valid for one year from date of issue.',
   false, true),
  ('New Year Family Buffet (Last Season)',
   'Ring in the new year with our grand family buffet at just ₹499 per head.',
   :'url' || '/offer-banners/offer-newyear.jpg', '2025-12-28', '2026-01-02',
   E'• ₹499 per head, kids under 8 free.\n• Grand spread of 40+ dishes.\n• Live music performance.\n• Pre-booking mandatory.',
   false, true)
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- Posts
-- ----------------------------------------------------------------------------
insert into public.posts (title, description, category, is_featured, is_published, published_at, created_at)
values
  ('Introducing the Special Green Park Biryani',
   E'We are proud to present our signature dish - the Special Green Park Biryani!\n\nDouble chicken, boiled egg, extra masala and a secret blend of spices, all slow-cooked on dum for that perfect aroma. This is the biryani our regulars have been asking for.\n\nAvailable every day at all our branches. Ask for it by name!',
   'New Dishes', true, true, now() - interval '3 days', now() - interval '3 days'),
  ('Live Music Nights Every Weekend',
   E'Join us every Friday and Saturday evening for live music performances from 7 PM onwards.\n\nEnjoy your favourite biryani and curries with soulful acoustic sets and popular Telugu hits. Seating is on a first-come, first-served basis.\n\nGather your family and friends for a memorable evening at Green Park!',
   'Events', false, true, now() - interval '6 days', now() - interval '6 days'),
  ('Celebrating Birthdays at Green Park',
   E'Another wonderful birthday celebration hosted at Green Park Family Restaurant this weekend!\n\nWe love being part of your special moments. Our party hall can comfortably seat up to 150 guests and we offer customised menus, cakes and decorations.\n\nBook your next celebration with us - call us for details.',
   'Customer Celebrations', false, true, now() - interval '9 days', now() - interval '9 days'),
  ('Sankranti Special Festive Feast',
   E'A grand Sankranti feast awaits you! Celebrate the harvest festival with authentic Andhra delicacies.\n\nSpecial menu includes Gongura chicken, jaggery sweets, garelu and traditional Pongal prepared by our master chefs.\n\nFestive lunch and dinner available throughout the Sankranti week.',
   'Festival Specials', false, true, now() - interval '12 days', now() - interval '12 days'),
  ('New Wood-Fired Tandoor Menu',
   E'Our new wood-fired tandoor is here, and with it comes an upgraded tandoori menu!\n\nFrom smoky paneer tikka and malai chaap to our signature full tandoori chicken, everything is now prepared in a traditional wood-fired clay oven.\n\nCome taste the difference fire makes.',
   'New Dishes', true, true, now() - interval '16 days', now() - interval '16 days'),
  ('Book Your Family Party With Us',
   E'Planning a family get-together, engagement, or a festive lunch?\n\nGreen Park offers a beautiful party hall, customised menus, and full event support - all at friendly prices.\n\nCall us today to check availability and get a free quote for your event.',
   'Announcements', false, true, now() - interval '20 days', now() - interval '20 days'),
  ('A Glimpse Inside Our Kitchen',
   E'Have you ever wondered how your biryani gets that perfect dum aroma? Here is a peek inside our kitchen.\n\nFresh spices ground every morning, basmati aged to perfection, and chefs with decades of experience - that is the Green Park way.\n\nFood photography from our daily kitchen routines.',
   'Food Photography', false, true, now() - interval '25 days', now() - interval '25 days'),
  ('Draft: Ugadi Special Menu Coming Soon',
   E'We are preparing something special for Ugadi. Stay tuned!',
   'Announcements', false, false, null, now() - interval '2 days')
on conflict do nothing;

-- Post images
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-biryani.jpg', 1 from public.posts p where p.title = 'Introducing the Special Green Park Biryani';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-music.jpg', 1 from public.posts p where p.title = 'Live Music Nights Every Weekend';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-birthday.jpg', 1 from public.posts p where p.title = 'Celebrating Birthdays at Green Park';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-birthday.jpg', 2 from public.posts p where p.title = 'Celebrating Birthdays at Green Park';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-sankranti.jpg', 1 from public.posts p where p.title = 'Sankranti Special Festive Feast';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-tandoori.jpg', 1 from public.posts p where p.title = 'New Wood-Fired Tandoor Menu';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-tandoori.jpg', 2 from public.posts p where p.title = 'New Wood-Fired Tandoor Menu';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-party.jpg', 1 from public.posts p where p.title = 'Book Your Family Party With Us';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-party.jpg', 2 from public.posts p where p.title = 'Book Your Family Party With Us';
insert into public.post_images (post_id, image_url, sort_order)
select p.id, :'url' || '/post-images/post-kitchen.jpg', 1 from public.posts p where p.title = 'A Glimpse Inside Our Kitchen';

-- ----------------------------------------------------------------------------
-- Gallery
-- ----------------------------------------------------------------------------
insert into public.gallery_images (title, category, image_url, is_published, sort_order)
values
  ('Main Dining Hall',           'Interior',          :'url' || '/gallery-images/gal-interior1.jpg', true, 1),
  ('Family Seating Area',        'Interior',          :'url' || '/gallery-images/gal-interior2.jpg', true, 2),
  ('Private Party Corner',       'Interior',          :'url' || '/gallery-images/gal-interior3.jpg', true, 3),
  ('Green Park Facade',          'Exterior',          :'url' || '/gallery-images/gal-exterior.jpg',  true, 4),
  ('Signature Biryani Platter',  'Food',              :'url' || '/gallery-images/gal-food1.jpg',     true, 5),
  ('Chef Special Spread',        'Food',              :'url' || '/gallery-images/gal-food2.jpg',     true, 6),
  ('Wood-Fired Tandoori',        'Food',              :'url' || '/gallery-images/gal-food3.jpg',     true, 7),
  ('Fresh Starters Platter',     'Food',              :'url' || '/gallery-images/gal-food4.jpg',     true, 8),
  ('Anniversary Celebration',    'Events',            :'url' || '/gallery-images/gal-event1.jpg',   true, 9),
  ('Live Music Night',           'Events',            :'url' || '/gallery-images/gal-event2.jpg',   true, 10),
  ('Birthday Party Setup',       'Special Occasions', :'url' || '/gallery-images/gal-celebration.jpg', true, 11)
on conflict do nothing;

-- ----------------------------------------------------------------------------
-- Restaurant contact details (real phone, WhatsApp, Google Maps link)
-- ----------------------------------------------------------------------------
update public.restaurant_info
set phone        = '+91 85208 10444',
    whatsapp     = '918520810444',
    maps_url     = 'https://maps.app.goo.gl/iXCVjkHzeiyT25ta7',
    instagram_url = null,
    facebook_url  = null
where id = 1;

-- ----------------------------------------------------------------------------
-- Customer reviews (published for the home showcase)
-- ----------------------------------------------------------------------------
insert into public.feedback_reviews (customer_name, kind, rating, message, contact, is_published, created_at) values
  ('Ravi Teja',   'review', 5, 'The Special Green Park Biryani is honestly the best in Rajahmundry. Generous portions and amazing flavour.',
   '91XXXXXXXXXX', true,  now() - interval '2 days'),
  ('Sravani',     'review', 5, 'Took the whole family on Sunday - great seating, quick service and the tandoori platter was superb.',
   '91XXXXXXXXXX', true,  now() - interval '5 days'),
  ('Kiran Kumar', 'review', 4, 'Loved the live music night. Food was great, especially the chicken 65. Will come again!',
   '91XXXXXXXXXX', true,  now() - interval '9 days'),
  ('Anitha',      'review', 5, 'Best family restaurant in Rajanagaram. Clean, affordable and the biryani is a must try.',
   '91XXXXXXXXXX', true,  now() - interval '14 days'),
  ('Prasad',      'suggestion', 4, 'Please add more vegetarian options on the weekend buffet.', null, false, now() - interval '1 day'),
  ('Unknown',     'complaint', 2, 'Waited a bit long for the starter on Saturday evening.', null, false, now() - interval '3 hours')
on conflict do nothing;
