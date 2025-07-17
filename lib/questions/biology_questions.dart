import '../models/test_question.dart';

final List<TestQuestion> biologyQuestions = [
  TestQuestion(
    id: 'bio_1',
    question: 'What is the basic unit of life?',
    options: ['Tissue', 'Organ', 'Cell', 'Organism'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'The cell is the smallest structural and functional unit of life.',
  ),
  TestQuestion(
    id: 'bio_2',
    question: 'Which organelle is responsible for photosynthesis?',
    options: ['Mitochondria', 'Chloroplast', 'Ribosome', 'Nucleus'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Chloroplasts contain chlorophyll and carry out photosynthesis in plant cells.',
  ),
  TestQuestion(
    id: 'bio_3',
    question: 'What is the process by which plants make their own food?',
    options: ['Respiration', 'Photosynthesis', 'Digestion', 'Excretion'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Photosynthesis is the process where plants use sunlight to convert CO2 and water into glucose.',
  ),
  TestQuestion(
    id: 'bio_4',
    question: 'Which blood cells are responsible for fighting infections?',
    options: ['Red blood cells', 'White blood cells', 'Platelets', 'Plasma'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'White blood cells (leukocytes) are part of the immune system and fight infections.',
  ),
  TestQuestion(
    id: 'bio_5',
    question: 'What is the powerhouse of the cell?',
    options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi apparatus'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation: 'Mitochondria produce ATP (energy) for cellular processes.',
  ),
  TestQuestion(
    id: 'bio_6',
    question:
        'Which gas do plants absorb from the atmosphere during photosynthesis?',
    options: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Plants absorb carbon dioxide from the atmosphere and release oxygen during photosynthesis.',
  ),
  TestQuestion(
    id: 'bio_7',
    question: 'What is DNA an abbreviation for?',
    options: [
      'Deoxyribonucleic acid',
      'Dinitrogen acid',
      'Deoxyribonitric acid',
      'Dinitrogenous acid',
    ],
    correctAnswer: 0,
    subject: 'Biology',
    explanation:
        'DNA stands for Deoxyribonucleic acid, which carries genetic information.',
  ),
  TestQuestion(
    id: 'bio_8',
    question:
        'Which organ system is responsible for transporting oxygen and nutrients throughout the body?',
    options: [
      'Digestive system',
      'Respiratory system',
      'Circulatory system',
      'Nervous system',
    ],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'The circulatory system transports oxygen, nutrients, and waste products throughout the body.',
  ),
  TestQuestion(
    id: 'bio_9',
    question: 'What is the process of cell division called?',
    options: ['Mitosis', 'Meiosis', 'Both mitosis and meiosis', 'Osmosis'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'Both mitosis (somatic cells) and meiosis (gametes) are types of cell division.',
  ),
  TestQuestion(
    id: 'bio_10',
    question: 'Which part of the brain controls balance and coordination?',
    options: ['Cerebrum', 'Cerebellum', 'Brainstem', 'Thalamus'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'The cerebellum is responsible for balance, coordination, and fine motor control.',
  ),
  TestQuestion(
    id: 'bio_11',
    question:
        'What is the molecule that carries genetic information from DNA to ribosomes?',
    options: ['tRNA', 'mRNA', 'rRNA', 'DNA polymerase'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'mRNA (messenger RNA) carries genetic information from DNA to ribosomes for protein synthesis.',
  ),
  TestQuestion(
    id: 'bio_12',
    question: 'Which hormone regulates blood sugar levels?',
    options: ['Adrenaline', 'Insulin', 'Thyroxine', 'Growth hormone'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Insulin, produced by the pancreas, regulates blood glucose levels.',
  ),
  TestQuestion(
    id: 'bio_13',
    question: 'What is the term for organisms that can make their own food?',
    options: ['Heterotrophs', 'Autotrophs', 'Consumers', 'Decomposers'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Autotrophs (like plants) can produce their own food through photosynthesis or chemosynthesis.',
  ),
  TestQuestion(
    id: 'bio_14',
    question: 'Which structure in plant cells provides support and protection?',
    options: ['Cell membrane', 'Cell wall', 'Cytoplasm', 'Vacuole'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'The cell wall, made of cellulose, provides structural support and protection to plant cells.',
  ),
  TestQuestion(
    id: 'bio_15',
    question:
        'What is the process by which organisms with favorable traits survive and reproduce?',
    options: ['Mutation', 'Natural selection', 'Genetic drift', 'Gene flow'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Natural selection is the process where organisms with advantageous traits are more likely to survive and reproduce.',
  ),
  TestQuestion(
    id: 'bio_16',
    question: 'Which organelle is responsible for protein synthesis?',
    options: ['Ribosome', 'Lysosome', 'Peroxisome', 'Centrosome'],
    correctAnswer: 0,
    subject: 'Biology',
    explanation:
        'Ribosomes are the cellular structures where protein synthesis occurs.',
  ),
  TestQuestion(
    id: 'bio_17',
    question: 'What is the largest organ in the human body?',
    options: ['Liver', 'Lungs', 'Brain', 'Skin'],
    correctAnswer: 3,
    subject: 'Biology',
    explanation:
        'The skin is the largest organ by surface area and weight in the human body.',
  ),
  TestQuestion(
    id: 'bio_18',
    question:
        'Which type of reproduction produces genetically identical offspring?',
    options: [
      'Sexual reproduction',
      'Asexual reproduction',
      'Cross-pollination',
      'Fertilization',
    ],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Asexual reproduction produces genetically identical offspring (clones) from a single parent.',
  ),
  TestQuestion(
    id: 'bio_19',
    question: 'What is the pH of normal human blood?',
    options: ['6.4', '7.4', '8.4', '9.4'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Normal human blood pH is approximately 7.4, which is slightly basic.',
  ),
  TestQuestion(
    id: 'bio_20',
    question: 'Which kingdom do mushrooms belong to?',
    options: ['Plantae', 'Animalia', 'Fungi', 'Protista'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'Mushrooms belong to the kingdom Fungi, which are distinct from plants and animals.',
  ),
  TestQuestion(
    id: 'bio_21',
    question: 'What is the function of the enzyme amylase?',
    options: [
      'Breaks down proteins',
      'Breaks down starch',
      'Breaks down fats',
      'Breaks down DNA',
    ],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Amylase is an enzyme that breaks down starch into simpler sugars.',
  ),
  TestQuestion(
    id: 'bio_22',
    question: 'Which structure connects muscle to bone?',
    options: ['Ligament', 'Tendon', 'Cartilage', 'Joint'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation: 'Tendons are connective tissues that attach muscles to bones.',
  ),
  TestQuestion(
    id: 'bio_23',
    question: 'What is the process of water movement through a plant called?',
    options: ['Photosynthesis', 'Transpiration', 'Respiration', 'Diffusion'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Transpiration is the process of water movement through plants and its evaporation from leaves.',
  ),
  TestQuestion(
    id: 'bio_24',
    question: 'Which blood type is considered the universal donor?',
    options: ['A', 'B', 'AB', 'O'],
    correctAnswer: 3,
    subject: 'Biology',
    explanation:
        'Type O blood is the universal donor because it lacks A and B antigens.',
  ),
  TestQuestion(
    id: 'bio_25',
    question: 'What is the study of heredity called?',
    options: ['Ecology', 'Genetics', 'Anatomy', 'Physiology'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Genetics is the branch of biology that studies heredity and variation in organisms.',
  ),
  TestQuestion(
    id: 'bio_26',
    question: 'Which part of the eye controls the amount of light entering?',
    options: ['Cornea', 'Lens', 'Iris', 'Retina'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'The iris controls the size of the pupil, regulating light entry into the eye.',
  ),
  TestQuestion(
    id: 'bio_27',
    question: 'What is the main function of the kidneys?',
    options: [
      'Produce hormones',
      'Filter blood and produce urine',
      'Digest food',
      'Pump blood',
    ],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'The kidneys filter waste products from blood and produce urine for excretion.',
  ),
  TestQuestion(
    id: 'bio_28',
    question: 'Which gas is released as a byproduct of cellular respiration?',
    options: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Carbon dioxide is produced as a waste product during cellular respiration.',
  ),
  TestQuestion(
    id: 'bio_29',
    question: 'What is the term for the variety of life in an ecosystem?',
    options: ['Population', 'Community', 'Biodiversity', 'Habitat'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation:
        'Biodiversity refers to the variety of living organisms in an ecosystem.',
  ),
  TestQuestion(
    id: 'bio_30',
    question: 'Which organelle contains the cell\'s genetic material?',
    options: ['Mitochondria', 'Nucleus', 'Ribosome', 'Endoplasmic reticulum'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'The nucleus contains the cell\'s DNA and controls cellular activities.',
  ),
  TestQuestion(
    id: 'bio_31',
    question:
        'What is the process by which organisms break down glucose to release energy?',
    options: [
      'Photosynthesis',
      'Cellular respiration',
      'Fermentation',
      'Digestion',
    ],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Cellular respiration breaks down glucose to produce ATP (energy) for cellular processes.',
  ),
  TestQuestion(
    id: 'bio_32',
    question: 'Which structure in bacteria contains genetic material?',
    options: ['Nucleus', 'Nucleoid', 'Ribosome', 'Plasmid'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Bacteria have a nucleoid region (not a true nucleus) that contains their genetic material.',
  ),
  TestQuestion(
    id: 'bio_33',
    question: 'What is the term for animals that eat both plants and meat?',
    options: ['Herbivores', 'Carnivores', 'Omnivores', 'Decomposers'],
    correctAnswer: 2,
    subject: 'Biology',
    explanation: 'Omnivores are animals that eat both plant and animal matter.',
  ),
  TestQuestion(
    id: 'bio_34',
    question:
        'Which hormone is responsible for the "fight or flight" response?',
    options: ['Insulin', 'Adrenaline', 'Thyroxine', 'Cortisol'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Adrenaline (epinephrine) triggers the fight or flight response in stressful situations.',
  ),
  TestQuestion(
    id: 'bio_35',
    question: 'What is the functional unit of the kidney?',
    options: ['Neuron', 'Nephron', 'Alveolus', 'Villus'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'The nephron is the functional unit of the kidney that filters blood and produces urine.',
  ),
  TestQuestion(
    id: 'bio_36',
    question: 'Which process results in the formation of gametes?',
    options: ['Mitosis', 'Meiosis', 'Binary fission', 'Budding'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Meiosis is the process that produces gametes (sex cells) with half the chromosome number.',
  ),
  TestQuestion(
    id: 'bio_37',
    question: 'What is the main component of plant cell walls?',
    options: ['Chitin', 'Cellulose', 'Keratin', 'Collagen'],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Cellulose is the main structural component of plant cell walls.',
  ),
  TestQuestion(
    id: 'bio_38',
    question:
        'Which scientist is known for the theory of evolution by natural selection?',
    options: [
      'Gregor Mendel',
      'Charles Darwin',
      'Louis Pasteur',
      'Alexander Fleming',
    ],
    correctAnswer: 1,
    subject: 'Biology',
    explanation:
        'Charles Darwin developed the theory of evolution by natural selection.',
  ),
  TestQuestion(
    id: 'bio_39',
    question:
        'What is the correct sequence of organization from smallest to largest?',
    options: [
      'Cell → Tissue → Organ → Organ system → Organism',
      'Tissue → Cell → Organ → Organism → Organ system',
      'Organ → Tissue → Cell → Organ system → Organism',
      'Cell → Organ → Tissue → Organ system → Organism',
    ],
    correctAnswer: 0,
    subject: 'Biology',
    explanation:
        'The correct hierarchy is: Cell → Tissue → Organ → Organ system → Organism.',
  ),
  TestQuestion(
    id: 'bio_40',
    question: 'Which molecule stores and transmits genetic information?',
    options: ['Protein', 'Carbohydrate', 'Lipid', 'Nucleic acid'],
    correctAnswer: 3,
    subject: 'Biology',
    explanation:
        'Nucleic acids (DNA and RNA) store and transmit genetic information in living organisms.',
  ),
];
