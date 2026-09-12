insert into public.movies (title, overview, poster_url, release_year, rating, genre)
values
  ('Le Voyage dans la Lune',
   'Un groupe de savants embarque dans un obus tiré vers la Lune. Premier grand film de science-fiction de l''histoire du cinéma.',
   'https://picsum.photos/seed/voyage-lune/300/450', 1902, 8.1, 'Aventure'),

  ('Nosferatu',
   'Un agent immobilier rend visite à un comte reclus des Carpates. Adaptation non autorisée de Dracula, devenue un classique de l''expressionnisme allemand.',
   'https://picsum.photos/seed/nosferatu/300/450', 1922, 7.9, 'Horreur'),

  ('Metropolis',
   'Dans une mégapole futuriste, les ouvriers vivent sous terre pendant que l''élite prospère en surface.',
   'https://picsum.photos/seed/metropolis/300/450', 1927, 8.3, 'Science-fiction'),

  ('Le Mécano de la General',
   'Un mécanicien de locomotive poursuit des espions ayant volé son train pendant la guerre de Sécession.',
   'https://picsum.photos/seed/general/300/450', 1926, 8.1, 'Comédie'),

  ('La Ruée vers l''or',
   'Un chercheur d''or affronte le froid, la faim et la solitude au Klondike.',
   'https://picsum.photos/seed/gold-rush/300/450', 1925, 8.2, 'Comédie'),

  ('La Nuit des morts-vivants',
   'Des inconnus se barricadent dans une ferme isolée alors que les morts reviennent à la vie.',
   'https://picsum.photos/seed/night-living-dead/300/450', 1968, 7.8, 'Horreur'),

  ('Le Cabinet du docteur Caligari',
   'Un forain hypnotiseur exhibe un somnambule qui prédit la mort des spectateurs.',
   'https://picsum.photos/seed/caligari/300/450', 1920, 8.0, 'Thriller'),

  ('Charade',
   'Une jeune veuve découvre que son mari assassiné cachait une fortune convoitée par plusieurs hommes.',
   'https://picsum.photos/seed/charade/300/450', 1963, 7.9, 'Policier')
on conflict (title) do nothing;
