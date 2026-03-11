class Game {
  final String title;
  final String description;
  final String genre;
  final String imageUrl;

  Game({
    required this.title,
    required this.description,
    required this.genre,
    required this.imageUrl,
  });
}

final List<Game> dummyGames = [
  Game(
    title: 'The Legend of Zelda: Breath of the Wild',
    description:
        'Step into a world of discovery, exploration, and adventure in The Legend of Zelda: Breath of the Wild, a boundary-breaking new game in the acclaimed series.',
    genre: 'Action-Adventure',
    imageUrl:
        'https://cdn.mobygames.com/covers/8437180-the-legend-of-zelda-breath-of-the-wild-nintendo-switch-front-cov.jpg',
  ),
  Game(
    title: 'Super Mario Odyssey',
    description:
        'Explore incredible places far from the Mushroom Kingdom as you join Mario and his new ally Cappy on a massive, globe-trotting 3D adventure.',
    genre: 'Platformer',
    imageUrl:
        'https://cdn.mobygames.com/covers/10038039-super-mario-odyssey-nintendo-switch-front-cover.jpg',
  ),
  Game(
    title: 'Red Dead Redemption 2',
    description:
        'Winner of over 175 Game of the Year Awards and recipient of over 250 perfect scores, RDR2 is the epic tale of outlaw Arthur Morgan and the infamous Van der Linde gang.',
    genre: 'Action-Adventure',
    imageUrl:
        'https://cdn.mobygames.com/covers/18319416-red-dead-redemption-ii-xbox-one-front-cover.jpg',
  ),
  Game(
    title: 'The Witcher 3: Wild Hunt',
    description:
        'As war rages on throughout the Northern Realms, you take on the greatest contract of your life — tracking down the Child of Prophecy, a living weapon that can alter the shape of the world.',
    genre: 'RPG',
    imageUrl:
        'https://cdn.mobygames.com/d0ca2b7c-ab6d-11ed-8ed2-02420a0001a0.webp',
  ),
  Game(
    title: 'God of War',
    description:
        'His vengeance against the Gods of Olympus years behind him, Kratos now lives as a man in the realm of Norse Gods and monsters. It is in this harsh, unforgiving world that he must fight to survive… and teach his son to do the same.',
    genre: 'Action-Adventure',
    imageUrl:
        'https://cdn.mobygames.com/914ce05e-af3a-11ed-8847-02420a0001be.webp',
  ),
];
