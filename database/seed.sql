-- DealMela — seed / dummy data for Phase 1 structural + visual preview.
--
-- IMPORTANT: every product below is a FICTIONAL placeholder — invented brand names,
-- invented specs, invented pricing. Do not treat any of it as real retailer data.
-- Before launch, replace every row here via the Phase 2 admin panel with real,
-- Admin-reviewed listings (each with a genuine, human-written "editorial_note" —
-- see Section 2.1 of the brief on Amazon's original-content requirement).
--
-- Images point at placehold.co — free, on-brand, and obviously placeholder
-- (no hotlinking of real product photography, no copyright exposure).

-- ============================================================
-- CATEGORIES
-- ============================================================
INSERT INTO categories (name, slug, parent_id, icon, sort_order) VALUES
('Digital Products & Electronics', 'electronics', NULL, 'cpu', 1),
('Fashion & Accessories',          'fashion',     NULL, 'shirt', 2);

INSERT INTO categories (name, slug, parent_id, icon, sort_order) VALUES
('Smartphones & Accessories', 'smartphones-accessories', (SELECT id FROM categories WHERE slug='electronics'), 'smartphone', 1),
('Laptops & Computing',       'laptops-computing',       (SELECT id FROM categories WHERE slug='electronics'), 'laptop', 2),
('Audio & Headphones',        'audio-headphones',        (SELECT id FROM categories WHERE slug='electronics'), 'headphones', 3),
('Smart Home & Gadgets',      'smart-home-gadgets',      (SELECT id FROM categories WHERE slug='electronics'), 'home', 4),
('Men''s Fashion',            'mens-fashion',            (SELECT id FROM categories WHERE slug='fashion'), 'shirt', 1),
('Women''s Fashion',          'womens-fashion',          (SELECT id FROM categories WHERE slug='fashion'), 'dress', 2),
('Footwear',                  'footwear',                (SELECT id FROM categories WHERE slug='fashion'), 'footprints', 3),
('Watches & Accessories',     'watches-accessories',     (SELECT id FROM categories WHERE slug='fashion'), 'watch', 4);

-- ============================================================
-- BANNERS
-- ============================================================
INSERT INTO banners (title, headline, subheadline, cta_text, cta_link, theme, is_default, is_active, start_date, end_date, sort_order) VALUES
('Default — Year-Round', 'Deals worth clicking for', 'Handpicked prices from Amazon, Flipkart & more — verified, not guessed.', 'Browse today''s deals', '/electronics', 'gold', true, true, NULL, NULL, 100),
('Monsoon Mega Sale 2026', 'Monsoon Mega Sale is live', 'Handpicked electronics & fashion deals, refreshed daily through the rains.', 'Shop the sale', '/electronics', 'marigold', false, true, '2026-06-15', '2026-07-15', 1),
('Diwali Dhamaka 2026', 'Diwali Dhamaka is coming', 'Our biggest curated drop of the year — festive fashion, gadgets & gifting.', 'Get notified', '/fashion', 'brick', false, true, '2026-11-01', '2026-11-15', 2);

-- ============================================================
-- PRODUCTS
-- Columns: name, slug, category, subcategory, brand, source_platform, source_platform_label,
--          affiliate_link, sku, current_price, original_price, images, specs, editorial_note,
--          source_rating, source_review_count, rating_checked_at, price_last_verified,
--          deal_end_date, status, is_featured, created_at
-- ============================================================

-- ---------- Smartphones & Accessories ----------
INSERT INTO products (name, slug, category_id, subcategory_id, brand, source_platform, affiliate_link, sku, current_price, original_price, images, specs, editorial_note, source_rating, source_review_count, rating_checked_at, price_last_verified, status, is_featured, created_at) VALUES
('Orbex Shield 20000mAh Fast Charging Power Bank', 'orbex-shield-20000mah-power-bank',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smartphones-accessories'),
 'Orbex', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-ORBEX-PB20K?tag=example-affid-21', 'ORB-PB20K-BLK',
 1499.00, 2799.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Orbex+Shield+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Orbex+Shield+%E2%80%94+Ports","https://placehold.co/900x900/FFF8EF/E67E22?text=Orbex+Shield+%E2%80%94+In+Use"]'::jsonb,
 '[{"label":"Capacity","value":"20,000mAh"},{"label":"Output","value":"22.5W fast charging, dual USB-A + USB-C"},{"label":"Charges","value":"iPhone 15 ~4.2x, average Android ~3.8x"},{"label":"Weight","value":"398g"}]'::jsonb,
 'We picked this because 20,000mAh at this price with real 22.5W output (not just advertised) is rare — most competitors throttle well below their claimed wattage. Good for anyone travelling over the festive season.',
 4.3, 8420, '2026-06-28', now() - interval '3 hours', 'active', true, now() - interval '2 days'),

('Nimbus MagSafe-Compatible Wireless Charging Stand', 'nimbus-magsafe-wireless-charging-stand',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smartphones-accessories'),
 'Nimbus', 'flipkart', 'https://www.flipkart.com/example-nimbus-charge-stand/p/EXAMPLEID?affid=example', 'NIM-MSST-01',
 1899.00, 2999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Nimbus+Stand+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Nimbus+Stand+%E2%80%94+Angle","https://placehold.co/900x900/FFF8EF/E67E22?text=Nimbus+Stand+%E2%80%94+Desk+Setup"]'::jsonb,
 '[{"label":"Output","value":"15W MagSafe-compatible, 10W standard Qi"},{"label":"Adjustable","value":"Tilts 0\u201345\u00b0 for Face ID / video calls"},{"label":"Cable","value":"1.5m braided USB-C included"}]'::jsonb,
 'Genuinely wobble-free at 15W, which a lot of budget magnetic stands aren''t — we tested it with a case on and it still snapped and held.',
 4.1, 2210, '2026-06-20', now() - interval '1 day', 'active', false, now() - interval '5 days'),

('Crestline ArmorGlass Edge-to-Edge Screen Protector (2-Pack)', 'crestline-armorglass-screen-protector-2-pack',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smartphones-accessories'),
 'Crestline', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-CREST-AG2P?tag=example-affid-21', 'CRST-AG-2PK',
 349.00, 799.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Crestline+ArmorGlass+%E2%80%94+Box","https://placehold.co/900x900/FFF8EF/B8802A?text=Crestline+ArmorGlass+%E2%80%94+Applied","https://placehold.co/900x900/FFF8EF/E67E22?text=Crestline+ArmorGlass+%E2%80%94+Kit+Contents"]'::jsonb,
 '[{"label":"Hardness","value":"9H tempered glass"},{"label":"Includes","value":"2 protectors, alignment tray, wipes, dust stickers"},{"label":"Compatibility","value":"Check listing for your exact model"}]'::jsonb,
 'The bundled alignment tray is the actual reason we picked this over cheaper loose-glass alternatives — bubble-free application without the usual fumbling.',
 4.4, 15600, '2026-06-25', now() - interval '6 hours', 'active', false, now() - interval '1 day'),

-- ---------- Laptops & Computing ----------
('Voltway SwiftPad 15.6" Laptop Sleeve with Organizer', 'voltway-swiftpad-15-6-laptop-sleeve',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='laptops-computing'),
 'Voltway', 'flipkart', 'https://www.flipkart.com/example-voltway-sleeve/p/EXAMPLEID2?affid=example', 'VLT-SP156-GRY',
 899.00, 1599.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Voltway+SwiftPad+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Voltway+SwiftPad+%E2%80%94+Organizer+Open","https://placehold.co/900x900/FFF8EF/E67E22?text=Voltway+SwiftPad+%E2%80%94+In+Bag"]'::jsonb,
 '[{"label":"Fits","value":"Up to 15.6\" laptops"},{"label":"Material","value":"Water-resistant nylon shell, fleece lining"},{"label":"Extra storage","value":"Front organizer for charger, mouse, cables"}]'::jsonb,
 'Padding felt noticeably thicker than similarly priced sleeves we compared it against, and the front organizer pocket is a genuinely useful addition, not just marketing copy.',
 4.2, 3040, '2026-06-18', now() - interval '2 days', 'active', false, now() - interval '6 days'),

('Pulsario ErgoLift Adjustable Laptop Stand', 'pulsario-ergolift-adjustable-laptop-stand',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='laptops-computing'),
 'Pulsario', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-PULS-ELS?tag=example-affid-21', 'PLS-ELS-SLV',
 1199.00, 2199.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Pulsario+ErgoLift+%E2%80%94+Folded","https://placehold.co/900x900/FFF8EF/B8802A?text=Pulsario+ErgoLift+%E2%80%94+Extended","https://placehold.co/900x900/FFF8EF/E67E22?text=Pulsario+ErgoLift+%E2%80%94+Desk+Setup"]'::jsonb,
 '[{"label":"Material","value":"Aluminium alloy"},{"label":"Height range","value":"6 adjustable levels"},{"label":"Max load","value":"10kg"},{"label":"Folded size","value":"Fits most laptop bag sleeves"}]'::jsonb,
 'Solid aluminium, not the flimsier plastic-and-foam stands common at this price — worth it for anyone doing long WFH days who wants their screen at eye level.',
 4.5, 6110, '2026-06-30', now() - interval '4 hours', 'active', true, now() - interval '3 days'),

('Orbex 65W GaN Compact Charger (USB-C, 3-Port)', 'orbex-65w-gan-compact-charger-3-port',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='laptops-computing'),
 'Orbex', 'other', 'https://inrdeals.example/redirect?merchant=croma&pid=EXAMPLE-ORBEX-65W', 'ORB-GAN65-3P',
 1699.00, 2999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Orbex+65W+GaN+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Orbex+65W+GaN+%E2%80%94+Size+Comparison","https://placehold.co/900x900/FFF8EF/E67E22?text=Orbex+65W+GaN+%E2%80%94+Ports"]'::jsonb,
 '[{"label":"Output","value":"65W total across 3 ports (2x USB-C + 1x USB-A)"},{"label":"Tech","value":"GaN — roughly 40% smaller than standard silicon chargers"},{"label":"Charges","value":"13\" laptop + phone simultaneously at full laptop speed"}]'::jsonb,
 'One charger replacing a laptop brick, a phone charger, and a desk charger is the whole pitch here, and it genuinely delivers 65W on the laptop port even with all three in use.',
 4.6, 4380, '2026-06-27', now() - interval '10 hours', 'active', false, now() - interval '4 days');

-- ---------- Audio & Headphones ----------
INSERT INTO products (name, slug, category_id, subcategory_id, brand, source_platform, affiliate_link, sku, current_price, original_price, images, specs, editorial_note, source_rating, source_review_count, rating_checked_at, price_last_verified, status, is_featured, created_at) VALUES
('Nimbus Audio AirBeat 3 True Wireless Earbuds', 'nimbus-audio-airbeat-3-tws-earbuds',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='audio-headphones'),
 'Nimbus Audio', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-NIMB-AB3?tag=example-affid-21', 'NIM-AB3-BLK',
 1799.00, 3499.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Nimbus+AirBeat+3+%E2%80%94+Case","https://placehold.co/900x900/FFF8EF/B8802A?text=Nimbus+AirBeat+3+%E2%80%94+Earbuds","https://placehold.co/900x900/FFF8EF/E67E22?text=Nimbus+AirBeat+3+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Battery life","value":"32 hours total with case"},{"label":"ANC","value":"Active noise cancellation, 35dB reduction"},{"label":"Water resistance","value":"IPX5"},{"label":"Latency","value":"Low-latency gaming mode, ~60ms"}]'::jsonb,
 'ANC at this price point is usually token — this one actually cuts meaningful office/traffic noise, not just a marketing checkbox. Best value pick in our audio category right now.',
 4.4, 21300, '2026-07-01', now() - interval '1 hour', 'active', true, now() - interval '1 day'),

('Crestline BassHalo Over-Ear Wireless Headphones', 'crestline-basshalo-over-ear-headphones',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='audio-headphones'),
 'Crestline', 'flipkart', 'https://www.flipkart.com/example-crestline-basshalo/p/EXAMPLEID3?affid=example', 'CRST-BH-NVY',
 2299.00, 3999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Crestline+BassHalo+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Crestline+BassHalo+%E2%80%94+Folded","https://placehold.co/900x900/FFF8EF/E67E22?text=Crestline+BassHalo+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Battery life","value":"40 hours playback"},{"label":"Drivers","value":"40mm dynamic, bass-forward tuning"},{"label":"Fold","value":"Collapsible with carry pouch"}]'::jsonb,
 'Genuinely comfortable past the 2-hour mark, which is where a lot of over-ear budget headphones start pinching — the memory foam earcups make the difference.',
 4.2, 9870, '2026-06-22', now() - interval '2 days', 'active', false, now() - interval '8 days'),

('Pulsario EchoBar 2.1 Compact Soundbar', 'pulsario-echobar-2-1-compact-soundbar',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='audio-headphones'),
 'Pulsario', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-PULS-EB21?tag=example-affid-21', 'PLS-EB21-BLK',
 3499.00, 5999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Pulsario+EchoBar+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Pulsario+EchoBar+%E2%80%94+Ports","https://placehold.co/900x900/FFF8EF/E67E22?text=Pulsario+EchoBar+%E2%80%94+TV+Setup"]'::jsonb,
 '[{"label":"Config","value":"2.1 channel with wired subwoofer"},{"label":"Output","value":"120W total"},{"label":"Connectivity","value":"Bluetooth 5.3, HDMI ARC, optical, AUX"}]'::jsonb,
 'The wired sub actually hits low-end that most all-in-one soundbars at this size fake with DSP — a noticeable upgrade over built-in TV speakers for the price.',
 4.3, 3260, '2026-06-24', now() - interval '3 days', 'active', false, now() - interval '9 days'),

-- ---------- Smart Home & Gadgets ----------
('Lumeo SmartGlow RGB Strip Light (5M, App-Controlled)', 'lumeo-smartglow-rgb-strip-light-5m',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smart-home-gadgets'),
 'Lumeo', 'flipkart', 'https://www.flipkart.com/example-lumeo-strip/p/EXAMPLEID4?affid=example', 'LUM-RGB5M-01',
 699.00, 1499.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Lumeo+SmartGlow+%E2%80%94+Box","https://placehold.co/900x900/FFF8EF/B8802A?text=Lumeo+SmartGlow+%E2%80%94+App","https://placehold.co/900x900/FFF8EF/E67E22?text=Lumeo+SmartGlow+%E2%80%94+Room+Setup"]'::jsonb,
 '[{"label":"Length","value":"5 metres, cuttable at marked lines"},{"label":"Control","value":"App + voice assistant (Alexa/Google)"},{"label":"Modes","value":"16 million colours, music sync"}]'::jsonb,
 'Music-sync mode has near-zero lag compared to cheaper strips we''ve seen that noticeably drift out of time with the beat — great for festive room decor.',
 4.1, 5540, '2026-06-19', now() - interval '5 hours', 'active', false, now() - interval '2 days'),

('Orbex PureAir Mini HEPA Air Purifier', 'orbex-pureair-mini-hepa-purifier',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smart-home-gadgets'),
 'Orbex', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-ORBEX-PAM?tag=example-affid-21', 'ORB-PAM-WHT',
 3999.00, 6499.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Orbex+PureAir+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Orbex+PureAir+%E2%80%94+Filter","https://placehold.co/900x900/FFF8EF/E67E22?text=Orbex+PureAir+%E2%80%94+Room+Setup"]'::jsonb,
 '[{"label":"Coverage","value":"Up to 250 sq ft"},{"label":"Filter","value":"True HEPA H13 + activated carbon"},{"label":"Noise","value":"22dB on lowest setting — near-silent"}]'::jsonb,
 'Relevant for anyone in a high-AQI city during winter smog season — the H13-rated filter is genuine, not just a "HEPA-style" marketing claim we see on cheaper units.',
 4.5, 2870, '2026-06-29', now() - interval '8 hours', 'active', true, now() - interval '12 hours'),

('Nimbus SmartClick Wi-Fi Video Doorbell', 'nimbus-smartclick-wifi-video-doorbell',
 (SELECT id FROM categories WHERE slug='electronics'), (SELECT id FROM categories WHERE slug='smart-home-gadgets'),
 'Nimbus', 'other', 'https://cuelinks.example/redirect?merchant=reliancedigital&pid=EXAMPLE-NIMB-SCD', 'NIM-SCD-BLK',
 2799.00, 4499.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Nimbus+SmartClick+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Nimbus+SmartClick+%E2%80%94+App+View","https://placehold.co/900x900/FFF8EF/E67E22?text=Nimbus+SmartClick+%E2%80%94+Installed"]'::jsonb,
 '[{"label":"Resolution","value":"1080p with night vision"},{"label":"Power","value":"Rechargeable battery, ~4 months per charge"},{"label":"Storage","value":"Free rolling 3-day cloud clips, no subscription required"}]'::jsonb,
 'No mandatory subscription to see clip history is the actual differentiator — most competitors at this price lock basic playback behind a monthly fee.',
 4.0, 1920, '2026-06-21', now() - interval '2 days', 'active', false, now() - interval '10 days'),

-- ---------- Men's Fashion ----------
('Thread & Twine Men''s Slim-Fit Kurta (Festive Collection)', 'thread-twine-mens-slim-fit-festive-kurta',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='mens-fashion'),
 'Thread & Twine', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-TNT-KURTA?tag=example-affid-21', 'TNT-KRT-MRN-M',
 899.00, 1999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Thread+%26+Twine+Kurta+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Thread+%26+Twine+Kurta+%E2%80%94+Fabric+Detail","https://placehold.co/900x900/FFF8EF/E67E22?text=Thread+%26+Twine+Kurta+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Fabric","value":"Pure cotton blend"},{"label":"Fit","value":"Slim, true to size"},{"label":"Care","value":"Machine washable, colour-safe"},{"label":"Sizes","value":"S to 3XL"}]'::jsonb,
 'The fabric weight is noticeably heavier/better-draping than typical fast-fashion kurtas at this price, which usually feel thin after one wash — good festive-season staple.',
 4.3, 4210, '2026-06-26', now() - interval '1 day', 'active', true, now() - interval '2 days'),

('Marrow & Co Men''s Bomber Jacket', 'marrow-co-mens-bomber-jacket',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='mens-fashion'),
 'Marrow & Co', 'flipkart', 'https://www.flipkart.com/example-marrow-bomber/p/EXAMPLEID5?affid=example', 'MRW-BMB-BLK-L',
 1599.00, 2999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Marrow+%26+Co+Bomber+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Marrow+%26+Co+Bomber+%E2%80%94+Back","https://placehold.co/900x900/FFF8EF/E67E22?text=Marrow+%26+Co+Bomber+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Material","value":"Polyester shell, ribbed cuffs & hem"},{"label":"Lining","value":"Quilted, light warmth for evenings"},{"label":"Sizes","value":"S to XXL"}]'::jsonb,
 'Zipper and stitching held up through repeated wear in our checks — often the first thing that fails on budget jackets, so worth flagging as a genuine strength here.',
 4.1, 1680, '2026-06-17', now() - interval '3 days', 'active', false, now() - interval '7 days'),

('Verve Studio Men''s Cotton Formal Shirt (Pack of 2)', 'verve-studio-mens-cotton-formal-shirt-pack-2',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='mens-fashion'),
 'Verve Studio', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-VRV-SHIRT2?tag=example-affid-21', 'VRV-SHT2-WHT-M',
 1099.00, 2199.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Verve+Studio+Shirts+%E2%80%94+Pack","https://placehold.co/900x900/FFF8EF/B8802A?text=Verve+Studio+Shirts+%E2%80%94+Fabric","https://placehold.co/900x900/FFF8EF/E67E22?text=Verve+Studio+Shirts+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Fabric","value":"100% cotton, non-iron finish"},{"label":"Fit","value":"Regular"},{"label":"Pack","value":"2 shirts, mix-and-match colours available"}]'::jsonb,
 'The non-iron finish is real — we''ve seen the same claim on shirts that still needed pressing. This one comes out of the wash genuinely wearable.',
 4.2, 3390, '2026-06-23', now() - interval '4 days', 'active', false, now() - interval '11 days'),

-- ---------- Women's Fashion ----------
('Kalindi Women''s Embroidered Anarkali Set', 'kalindi-womens-embroidered-anarkali-set',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='womens-fashion'),
 'Kalindi', 'flipkart', 'https://www.flipkart.com/example-kalindi-anarkali/p/EXAMPLEID6?affid=example', 'KLN-ANRK-TEA-M',
 1799.00, 3999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Kalindi+Anarkali+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Kalindi+Anarkali+%E2%80%94+Embroidery+Detail","https://placehold.co/900x900/FFF8EF/E67E22?text=Kalindi+Anarkali+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Fabric","value":"Georgette with thread embroidery"},{"label":"Set includes","value":"Kurta, churidar, dupatta"},{"label":"Sizes","value":"XS to 3XL"}]'::jsonb,
 'Embroidery is machine-thread but genuinely dense rather than sparse-and-scattered, which is where similarly priced sets usually cut corners — reads well for festive occasions.',
 4.4, 6720, '2026-06-30', now() - interval '2 hours', 'active', true, now() - interval '18 hours'),

('Solstice Women''s Wrap Maxi Dress', 'solstice-womens-wrap-maxi-dress',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='womens-fashion'),
 'Solstice', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-SOLS-WMD?tag=example-affid-21', 'SOL-WMD-RST-S',
 1299.00, 2599.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Solstice+Maxi+Dress+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Solstice+Maxi+Dress+%E2%80%94+Fabric","https://placehold.co/900x900/FFF8EF/E67E22?text=Solstice+Maxi+Dress+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Fabric","value":"Rayon crepe, flowy drape"},{"label":"Fit","value":"Wrap-tie waist, adjustable"},{"label":"Sizes","value":"XS to XL"}]'::jsonb,
 'The wrap-tie actually holds through movement instead of loosening within an hour, which is the usual failure point on cheaper wrap dresses.',
 4.0, 2140, '2026-06-16', now() - interval '5 days', 'active', false, now() - interval '13 days'),

('Thread & Twine Women''s Handloom Cotton Saree', 'thread-twine-womens-handloom-cotton-saree',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='womens-fashion'),
 'Thread & Twine', 'other', 'https://inrdeals.example/redirect?merchant=myntra&pid=EXAMPLE-TNT-SAREE', 'TNT-SAR-IND-FS',
 1499.00, 2999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Thread+%26+Twine+Saree+%E2%80%94+Full","https://placehold.co/900x900/FFF8EF/B8802A?text=Thread+%26+Twine+Saree+%E2%80%94+Border+Detail","https://placehold.co/900x900/FFF8EF/E67E22?text=Thread+%26+Twine+Saree+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Fabric","value":"Handloom cotton"},{"label":"Blouse piece","value":"Included, unstitched"},{"label":"Length","value":"6.3m with blouse piece"}]'::jsonb,
 'Handloom texture is genuinely uneven in the way real handloom is — not a printed imitation, which is common at this price band and worth calling out clearly.',
 4.5, 3980, '2026-06-28', now() - interval '9 hours', 'active', false, now() - interval '4 days'),

-- ---------- Footwear ----------
('Marrow & Co Men''s Leather Sneakers', 'marrow-co-mens-leather-sneakers',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='footwear'),
 'Marrow & Co', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-MRW-SNKR?tag=example-affid-21', 'MRW-SNK-WHT-9',
 2199.00, 3999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Marrow+%26+Co+Sneakers+%E2%80%94+Side","https://placehold.co/900x900/FFF8EF/B8802A?text=Marrow+%26+Co+Sneakers+%E2%80%94+Sole","https://placehold.co/900x900/FFF8EF/E67E22?text=Marrow+%26+Co+Sneakers+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Upper","value":"Genuine leather"},{"label":"Sole","value":"EVA cushioned, non-marking"},{"label":"Sizes","value":"UK 6 to UK 11"}]'::jsonb,
 'Real leather upper at this price is the exception, not the rule — most "leather look" sneakers in this range are PU. Breaks in within 2-3 wears based on our check.',
 4.3, 5230, '2026-06-27', now() - interval '14 hours', 'active', true, now() - interval '3 days'),

('Solstice Women''s Block Heel Sandals', 'solstice-womens-block-heel-sandals',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='footwear'),
 'Solstice', 'flipkart', 'https://www.flipkart.com/example-solstice-heels/p/EXAMPLEID7?affid=example', 'SOL-BHS-TAN-38',
 1099.00, 1999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Solstice+Sandals+%E2%80%94+Side","https://placehold.co/900x900/FFF8EF/B8802A?text=Solstice+Sandals+%E2%80%94+Sole","https://placehold.co/900x900/FFF8EF/E67E22?text=Solstice+Sandals+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Heel height","value":"2.5 inches, block heel"},{"label":"Material","value":"Faux leather straps, cushioned footbed"},{"label":"Sizes","value":"UK 3 to UK 8"}]'::jsonb,
 'Block heel stays stable on the kind of uneven flooring you actually encounter at weddings/events — a real practical edge over stiletto styles in the same price range.',
 4.1, 2870, '2026-06-24', now() - interval '2 days', 'active', false, now() - interval '6 days'),

('Verve Studio Unisex Canvas Slip-Ons', 'verve-studio-unisex-canvas-slip-ons',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='footwear'),
 'Verve Studio', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-VRV-SLIP?tag=example-affid-21', 'VRV-SLP-NVY-8',
 699.00, 1399.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Verve+Studio+Slip-Ons+%E2%80%94+Side","https://placehold.co/900x900/FFF8EF/B8802A?text=Verve+Studio+Slip-Ons+%E2%80%94+Sole","https://placehold.co/900x900/FFF8EF/E67E22?text=Verve+Studio+Slip-Ons+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Material","value":"Breathable canvas upper"},{"label":"Sole","value":"Rubber, flexible"},{"label":"Sizes","value":"UK 5 to UK 11, unisex fit"}]'::jsonb,
 'Simple, and that''s the point — a genuinely versatile everyday pair rather than a trend piece, at a price where you won''t feel precious about wearing them daily.',
 4.0, 4120, '2026-06-15', now() - interval '6 days', 'active', false, now() - interval '15 days'),

-- ---------- Watches & Accessories ----------
('Kalindi Chronograph Steel-Strap Watch', 'kalindi-chronograph-steel-strap-watch',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='watches-accessories'),
 'Kalindi', 'amazon', 'https://www.amazon.in/dp/EXAMPLE-KLN-CHRW?tag=example-affid-21', 'KLN-CHR-SLV',
 2499.00, 4999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Kalindi+Watch+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Kalindi+Watch+%E2%80%94+Strap+Detail","https://placehold.co/900x900/FFF8EF/E67E22?text=Kalindi+Watch+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Movement","value":"Quartz chronograph"},{"label":"Water resistance","value":"5 ATM"},{"label":"Strap","value":"Stainless steel, adjustable"}]'::jsonb,
 'Chronograph sub-dials are functional, not just printed decoration — a detail that separates it from visually similar watches at half the spec.',
 4.4, 3650, '2026-06-29', now() - interval '7 hours', 'active', true, now() - interval '20 hours'),

('Solstice Oxidised Silver Jhumka Earrings', 'solstice-oxidised-silver-jhumka-earrings',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='watches-accessories'),
 'Solstice', 'other', 'https://cuelinks.example/redirect?merchant=myntra&pid=EXAMPLE-SOL-JHUM', 'SOL-JHUM-OXD',
 449.00, 999.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Solstice+Jhumkas+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Solstice+Jhumkas+%E2%80%94+Detail","https://placehold.co/900x900/FFF8EF/E67E22?text=Solstice+Jhumkas+%E2%80%94+Worn"]'::jsonb,
 '[{"label":"Material","value":"Oxidised German silver"},{"label":"Closure","value":"Push-back with hook support"},{"label":"Weight","value":"Lightweight, comfortable for all-day wear"}]'::jsonb,
 'Genuinely lightweight for the size — bigger jhumkas in this material often drag on the earlobe by evening; these didn''t in our check.',
 4.3, 7840, '2026-06-26', now() - interval '11 hours', 'active', false, now() - interval '1 day'),

('Marrow & Co Genuine Leather Bifold Wallet', 'marrow-co-genuine-leather-bifold-wallet',
 (SELECT id FROM categories WHERE slug='fashion'), (SELECT id FROM categories WHERE slug='watches-accessories'),
 'Marrow & Co', 'flipkart', 'https://www.flipkart.com/example-marrow-wallet/p/EXAMPLEID8?affid=example', 'MRW-WLT-BRN',
 799.00, 1599.00,
 '["https://placehold.co/900x900/FFF8EF/A32C1E?text=Marrow+%26+Co+Wallet+%E2%80%94+Front","https://placehold.co/900x900/FFF8EF/B8802A?text=Marrow+%26+Co+Wallet+%E2%80%94+Open","https://placehold.co/900x900/FFF8EF/E67E22?text=Marrow+%26+Co+Wallet+%E2%80%94+Detail"]'::jsonb,
 '[{"label":"Material","value":"Genuine leather"},{"label":"Slots","value":"8 card slots, 2 bill compartments, ID window"},{"label":"Dimensions","value":"11cm x 9cm folded"}]'::jsonb,
 'Stitching is double-run along every edge rather than single-stitched, which is usually the first place budget wallets fray — small detail, meaningfully longer lifespan.',
 4.2, 6390, '2026-06-20', now() - interval '3 days', 'active', false, now() - interval '9 days');

-- ============================================================
-- CLICK EVENTS — seeded activity so "Trending This Week" has honest signal to rank by
-- (weighted toward featured + audio/electronics items, spread across the last 7 days)
-- ============================================================
INSERT INTO click_events (product_id, source_page, clicked_at)
SELECT p.id, page, now() - (random() * interval '7 days')
FROM products p
CROSS JOIN LATERAL (
  SELECT unnest(ARRAY['homepage','category','product_detail','search','trending']) AS page
) pages
CROSS JOIN LATERAL (
  SELECT generate_series(1,
    CASE
      WHEN p.is_featured THEN 9
      WHEN p.slug LIKE '%airbeat%' OR p.slug LIKE '%anarkali%' THEN 7
      ELSE (2 + (p.id % 4))
    END
  )
) reps
WHERE random() < 0.35;
