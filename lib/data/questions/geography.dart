import '../../domain/models/test_question.dart';

final List<TestQuestion> geographyQuestions = [
  TestQuestion(
    id: 'geo_1',
    question: 'The capital of Nigeria is:',
    options: ['Lagos', 'Kano', 'Abuja', 'Port Harcourt'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Abuja is the capital city of Nigeria, located in the Federal Capital Territory.',
  ),
  TestQuestion(
    id: 'geo_2',
    question: 'Which river is the longest in Nigeria?',
    options: ['River Benue', 'River Niger', 'River Cross', 'River Kaduna'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'River Niger is the longest river in Nigeria, flowing from Guinea through Nigeria to the Atlantic Ocean.',
  ),
  TestQuestion(
    id: 'geo_3',
    question: 'Nigeria is located in which hemisphere?',
    options: [
      'Northern only',
      'Southern only',
      'Both Northern and Eastern',
      'Both Northern and Southern',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Nigeria is located in both the Northern and Eastern hemispheres.',
  ),
  TestQuestion(
    id: 'geo_4',
    question: 'The savanna vegetation in Nigeria is characterized by:',
    options: [
      'Dense forests only',
      'Grasslands with scattered trees',
      'Desert conditions',
      'Swamp vegetation',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Savanna vegetation consists of grasslands with scattered trees, typical of Nigeria\'s middle belt.',
  ),
  TestQuestion(
    id: 'geo_5',
    question: 'Lagos is located in which geographical zone of Nigeria?',
    options: [
      'Guinea Savanna',
      'Sudan Savanna',
      'Forest Zone',
      'Sahel Savanna',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation: 'Lagos is located in the Forest Zone of southern Nigeria.',
  ),
  TestQuestion(
    id: 'geo_6',
    question: 'Which plateau is located in central Nigeria?',
    options: [
      'Mambilla Plateau',
      'Jos Plateau',
      'Obudu Plateau',
      'Udi Plateau',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Jos Plateau is the major plateau located in central Nigeria, known for its tin mining.',
  ),
  TestQuestion(
    id: 'geo_7',
    question: 'Nigeria experiences how many distinct seasons?',
    options: ['Two', 'Three', 'Four', 'Five'],
    correctAnswer: 0,
    subject: 'Geography',
    explanation:
        'Nigeria experiences two main seasons: the wet (rainy) season and the dry season.',
  ),
  TestQuestion(
    id: 'geo_8',
    question: 'The Niger Delta is important for:',
    options: [
      'Cotton production',
      'Oil production',
      'Gold mining',
      'Cattle rearing',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation: 'The Niger Delta is Nigeria\'s major oil-producing region.',
  ),
  TestQuestion(
    id: 'geo_9',
    question: 'Which wind brings rainfall to southern Nigeria?',
    options: [
      'Harmattan',
      'Southwest Monsoon',
      'Northeast Trade Wind',
      'Chinook',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'The Southwest Monsoon wind brings moisture and rainfall to southern Nigeria.',
  ),
  TestQuestion(
    id: 'geo_10',
    question: 'The driest part of Nigeria is in the:',
    options: ['Southwest', 'Southeast', 'Northwest', 'Northeast'],
    correctAnswer: 3,
    subject: 'Geography',
    explanation:
        'The northeastern part of Nigeria, including areas near Lake Chad, is the driest.',
  ),
  TestQuestion(
    id: 'geo_11',
    question: 'Which crop is most associated with the Middle Belt of Nigeria?',
    options: ['Cocoa', 'Oil palm', 'Yam', 'Cotton'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Yam is the most important crop in Nigeria\'s Middle Belt region.',
  ),
  TestQuestion(
    id: 'geo_12',
    question: 'The confluence of Rivers Niger and Benue is located at:',
    options: ['Kano', 'Kaduna', 'Lokoja', 'Maiduguri'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Lokoja is located at the confluence where Rivers Niger and Benue meet.',
  ),
  TestQuestion(
    id: 'geo_13',
    question: 'Nigeria\'s coastline stretches for approximately:',
    options: ['500 km', '600 km', '700 km', '800 km'],
    correctAnswer: 3,
    subject: 'Geography',
    explanation:
        'Nigeria\'s coastline along the Atlantic Ocean stretches for about 800 kilometers.',
  ),
  TestQuestion(
    id: 'geo_14',
    question: 'Which state in Nigeria has the highest population?',
    options: ['Lagos', 'Kano', 'Rivers', 'Oyo'],
    correctAnswer: 0,
    subject: 'Geography',
    explanation:
        'Lagos State has the highest population in Nigeria, despite being one of the smallest by area.',
  ),
  TestQuestion(
    id: 'geo_15',
    question: 'The Sahel region of Nigeria is characterized by:',
    options: [
      'Heavy rainfall',
      'Semi-arid conditions',
      'Dense forests',
      'Swamplands',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'The Sahel region in northern Nigeria is characterized by semi-arid conditions.',
  ),
  TestQuestion(
    id: 'geo_16',
    question: 'Which mining activity is prominent on the Jos Plateau?',
    options: ['Gold mining', 'Tin mining', 'Coal mining', 'Iron ore mining'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Tin mining has been the major mining activity on the Jos Plateau for over a century.',
  ),
  TestQuestion(
    id: 'geo_17',
    question: 'The mangrove vegetation in Nigeria is found in:',
    options: [
      'Northern Nigeria',
      'Central Nigeria',
      'Coastal areas',
      'Plateau regions',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Mangrove vegetation thrives in the coastal and deltaic areas of southern Nigeria.',
  ),
  TestQuestion(
    id: 'geo_18',
    question: 'Nigeria\'s highest peak is:',
    options: ['Chappal Waddi', 'Zuma Rock', 'Aso Rock', 'Shere Hills'],
    correctAnswer: 0,
    subject: 'Geography',
    explanation:
        'Chappal Waddi in Taraba State is Nigeria\'s highest peak at 2,419 meters.',
  ),
  TestQuestion(
    id: 'geo_19',
    question: 'Which ocean borders Nigeria?',
    options: [
      'Indian Ocean',
      'Pacific Ocean',
      'Atlantic Ocean',
      'Arctic Ocean',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation: 'Nigeria is bordered by the Atlantic Ocean to the south.',
  ),
  TestQuestion(
    id: 'geo_20',
    question: 'The Guinea Savanna belt is suitable for growing:',
    options: [
      'Cocoa and oil palm',
      'Millet and sorghum',
      'Maize and yam',
      'Rice and cassava',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'The Guinea Savanna has adequate rainfall for growing maize and yam.',
  ),
  TestQuestion(
    id: 'geo_21',
    question: 'Erosion is a major environmental problem in:',
    options: [
      'Northern Nigeria',
      'Eastern Nigeria',
      'Western Nigeria',
      'Central Nigeria',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Gully erosion is particularly severe in the southeastern states of Nigeria.',
  ),
  TestQuestion(
    id: 'geo_22',
    question: 'Which factor most influences Nigeria\'s climate?',
    options: ['Altitude', 'Ocean currents', 'Latitude', 'Mountains'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Nigeria\'s position near the equator (latitude) is the primary factor influencing its tropical climate.',
  ),
  TestQuestion(
    id: 'geo_23',
    question: 'The economic trees in Nigeria\'s forest zone include:',
    options: [
      'Baobab and acacia',
      'Mahogany and iroko',
      'Palm and locust bean',
      'Neem and eucalyptus',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Mahogany and iroko are valuable hardwood trees found in Nigeria\'s forest zone.',
  ),
  TestQuestion(
    id: 'geo_24',
    question: 'Which river system drains the largest area in Nigeria?',
    options: [
      'Niger-Benue system',
      'Cross River system',
      'Komadugu-Yobe system',
      'Ogun River system',
    ],
    correctAnswer: 0,
    subject: 'Geography',
    explanation:
        'The Niger-Benue river system drains the largest area in Nigeria.',
  ),
  TestQuestion(
    id: 'geo_25',
    question: 'Nigeria shares its longest border with:',
    options: ['Cameroon', 'Chad', 'Niger Republic', 'Benin Republic'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Nigeria shares its longest international border with Niger Republic to the north.',
  ),
  TestQuestion(
    id: 'geo_26',
    question: 'The rainforest belt in Nigeria receives annual rainfall of:',
    options: ['500-1000mm', '1000-1500mm', '1500-2500mm', '2500-4000mm'],
    correctAnswer: 3,
    subject: 'Geography',
    explanation:
        'The rainforest belt receives very high rainfall, typically 2500-4000mm annually.',
  ),
  TestQuestion(
    id: 'geo_27',
    question: 'Desertification in Nigeria primarily affects:',
    options: [
      'Southern states',
      'Eastern states',
      'Northern states',
      'Western states',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Desertification is a major environmental challenge in Nigeria\'s northern states.',
  ),
  TestQuestion(
    id: 'geo_28',
    question: 'The most suitable soil for cocoa cultivation in Nigeria is:',
    options: ['Sandy soil', 'Clay soil', 'Forest soil', 'Alluvial soil'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Rich forest soils in southern Nigeria are most suitable for cocoa cultivation.',
  ),
  TestQuestion(
    id: 'geo_29',
    question: 'Which city is known as the "Centre of Excellence"?',
    options: ['Abuja', 'Lagos', 'Kano', 'Port Harcourt'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Lagos is known as the "Centre of Excellence" and is Nigeria\'s commercial capital.',
  ),
  TestQuestion(
    id: 'geo_30',
    question: 'The Middle Belt of Nigeria is characterized by:',
    options: [
      'Desert conditions',
      'Tropical rainforest',
      'Guinea savanna vegetation',
      'Mangrove swamps',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'The Middle Belt is characterized by Guinea savanna vegetation with mixed farming.',
  ),
  TestQuestion(
    id: 'geo_31',
    question: 'Which dam is the largest in Nigeria?',
    options: ['Shiroro Dam', 'Jebba Dam', 'Kainji Dam', 'Tiga Dam'],
    correctAnswer: 2,
    subject: 'Geography',
    explanation: 'Kainji Dam on River Niger is the largest dam in Nigeria.',
  ),
  TestQuestion(
    id: 'geo_32',
    question: 'The Inter-Tropical Convergence Zone (ITCZ) affects Nigeria by:',
    options: [
      'Causing earthquakes',
      'Determining rainfall patterns',
      'Creating mountains',
      'Forming rivers',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'The ITCZ\'s seasonal movement determines Nigeria\'s wet and dry seasons.',
  ),
  TestQuestion(
    id: 'geo_33',
    question: 'Which vegetation zone covers the largest area in Nigeria?',
    options: ['Rainforest', 'Guinea Savanna', 'Sudan Savanna', 'Sahel Savanna'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Guinea Savanna covers the largest area in Nigeria, spanning the middle belt.',
  ),
  TestQuestion(
    id: 'geo_34',
    question: 'The oil palm belt of Nigeria is located in the:',
    options: ['Far north', 'Middle belt', 'Southwest', 'Southeast'],
    correctAnswer: 3,
    subject: 'Geography',
    explanation:
        'The oil palm belt is concentrated in southeastern Nigeria where conditions are favorable.',
  ),
  TestQuestion(
    id: 'geo_35',
    question: 'Which factor contributes most to soil formation in Nigeria?',
    options: ['Wind erosion', 'Climate', 'Mining activities', 'Ocean waves'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Climate, particularly temperature and rainfall, is the most important factor in soil formation.',
  ),
  TestQuestion(
    id: 'geo_36',
    question: 'The Great Escarpment in Nigeria runs through:',
    options: [
      'East-West direction',
      'North-South direction',
      'Northeast-Southwest',
      'Northwest-Southeast',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'The Great Escarpment runs roughly in a North-South direction through central Nigeria.',
  ),
  TestQuestion(
    id: 'geo_37',
    question: 'Which economic activity is dominant in Nigeria\'s far north?',
    options: ['Fishing', 'Pastoralism', 'Logging', 'Mining'],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'Pastoralism (nomadic cattle herding) is the dominant economic activity in Nigeria\'s far north.',
  ),
  TestQuestion(
    id: 'geo_38',
    question: 'The best explanation for Lagos\'s rapid population growth is:',
    options: [
      'High birth rates only',
      'Low death rates only',
      'Rural-urban migration',
      'International immigration',
    ],
    correctAnswer: 2,
    subject: 'Geography',
    explanation:
        'Rural-urban migration due to economic opportunities is the main driver of Lagos\'s population growth.',
  ),
  TestQuestion(
    id: 'geo_39',
    question: 'Nigeria\'s main export crop is:',
    options: ['Cocoa', 'Cotton', 'Groundnuts', 'Oil palm'],
    correctAnswer: 0,
    subject: 'Geography',
    explanation:
        'Cocoa is Nigeria\'s main agricultural export crop, primarily grown in the southwest.',
  ),
  TestQuestion(
    id: 'geo_40',
    question: 'The harmattan wind in Nigeria is characterized by:',
    options: [
      'High humidity',
      'Dry and dusty conditions',
      'Heavy rainfall',
      'Coastal fog',
    ],
    correctAnswer: 1,
    subject: 'Geography',
    explanation:
        'The harmattan is a dry, dusty wind that blows from the Sahara Desert during the dry season.',
  ),
];
