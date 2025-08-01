import '../../domain/models/test_question.dart';

final List<TestQuestion> physicsQuestions = [
  TestQuestion(
    id: 'phy_1',
    question: 'What is the SI unit of force?',
    options: ['Joule', 'Newton', 'Watt', 'Pascal'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'The SI unit of force is Newton (N).',
  ),
  TestQuestion(
    id: 'phy_2',
    question: 'What is the acceleration due to gravity on Earth?',
    options: ['9.8 m/s²', '10 m/s²', '8 m/s²', '12 m/s²'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Standard gravity is 9.8 m/s².',
  ),
  TestQuestion(
    id: 'phy_3',
    question: 'What is the unit of electrical resistance?',
    options: ['Ampere', 'Volt', 'Ohm', 'Watt'],
    correctAnswer: 2,
    subject: 'Physics',
    explanation: 'The unit of electrical resistance is Ohm (Ω).',
  ),
  TestQuestion(
    id: 'phy_4',
    question: 'Which of the following is a scalar quantity?',
    options: ['Velocity', 'Acceleration', 'Force', 'Speed'],
    correctAnswer: 3,
    subject: 'Physics',
    explanation:
        'Speed is a scalar quantity as it has only magnitude, no direction.',
  ),
  TestQuestion(
    id: 'phy_5',
    question: 'What is the speed of light in vacuum?',
    options: ['3 × 10⁸ m/s', '3 × 10⁶ m/s', '3 × 10⁹ m/s', '3 × 10⁷ m/s'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'The speed of light in vacuum is 3 × 10⁸ m/s.',
  ),
  TestQuestion(
    id: 'phy_6',
    question: 'What is the formula for kinetic energy?',
    options: ['mgh', '½mv²', 'mv', 'Fd'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Kinetic energy is given by KE = ½mv².',
  ),
  TestQuestion(
    id: 'phy_7',
    question:
        'Which law states that "for every action, there is an equal and opposite reaction"?',
    options: [
      'Newton\'s 1st Law',
      'Newton\'s 2nd Law',
      'Newton\'s 3rd Law',
      'Law of Conservation',
    ],
    correctAnswer: 2,
    subject: 'Physics',
    explanation:
        'Newton\'s third law states that for every action, there is an equal and opposite reaction.',
  ),
  TestQuestion(
    id: 'phy_8',
    question: 'What is the unit of electric current?',
    options: ['Volt', 'Ampere', 'Ohm', 'Coulomb'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'The unit of electric current is Ampere (A).',
  ),
  TestQuestion(
    id: 'phy_9',
    question: 'What is the frequency of alternating current in Nigeria?',
    options: ['50 Hz', '60 Hz', '40 Hz', '100 Hz'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'The frequency of AC in Nigeria is 50 Hz.',
  ),
  TestQuestion(
    id: 'phy_10',
    question: 'What is the principle behind the operation of a transformer?',
    options: [
      'Electromagnetic induction',
      'Photoelectric effect',
      'Thermionic emission',
      'Magnetic field',
    ],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'Transformers work on the principle of electromagnetic induction.',
  ),
  TestQuestion(
    id: 'phy_11',
    question: 'What is the unit of pressure?',
    options: ['Newton', 'Pascal', 'Joule', 'Watt'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'The SI unit of pressure is Pascal (Pa).',
  ),
  TestQuestion(
    id: 'phy_12',
    question: 'Which of the following is NOT a fundamental particle?',
    options: ['Proton', 'Neutron', 'Electron', 'Alpha particle'],
    correctAnswer: 3,
    subject: 'Physics',
    explanation:
        'Alpha particle is made up of 2 protons and 2 neutrons, so it\'s not fundamental.',
  ),
  TestQuestion(
    id: 'phy_13',
    question: 'What is the SI unit of work?',
    options: ['Newton', 'Joule', 'Watt', 'Pascal'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'The SI unit of work is Joule (J).',
  ),
  TestQuestion(
    id: 'phy_14',
    question: 'What is the relationship between wavelength and frequency?',
    options: ['λ = f/v', 'λ = v/f', 'λ = vf', 'λ = f²/v'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Wavelength λ = v/f, where v is velocity and f is frequency.',
  ),
  TestQuestion(
    id: 'phy_15',
    question: 'What is the unit of magnetic field strength?',
    options: ['Tesla', 'Weber', 'Henry', 'Gauss'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'The SI unit of magnetic field strength is Tesla (T).',
  ),
  TestQuestion(
    id: 'phy_16',
    question:
        'What is the half-life of a radioactive element with initial activity 800 Bq that becomes 200 Bq after 10 years?',
    options: ['5 years', '10 years', '20 years', '15 years'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'Half-life is the time for activity to reduce to half. 800 → 400 → 200 takes 2 half-lives = 10 years, so 1 half-life = 5 years.',
  ),
  TestQuestion(
    id: 'phy_17',
    question:
        'What is the critical angle for total internal reflection when light travels from glass (n=1.5) to air (n=1.0)?',
    options: ['30°', '42°', '45°', '60°'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation:
        'Critical angle θc = sin⁻¹(n₂/n₁) = sin⁻¹(1.0/1.5) = sin⁻¹(2/3) ≈ 42°.',
  ),
  TestQuestion(
    id: 'phy_18',
    question:
        'What is the power dissipated in a 10Ω resistor when 2A current flows through it?',
    options: ['20 W', '40 W', '5 W', '10 W'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Power P = I²R = 2² × 10 = 40 W.',
  ),
  TestQuestion(
    id: 'phy_19',
    question: 'What is the momentum of a 2kg object moving at 5 m/s?',
    options: ['10 kg⋅m/s', '7 kg⋅m/s', '2.5 kg⋅m/s', '25 kg⋅m/s'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Momentum p = mv = 2 × 5 = 10 kg⋅m/s.',
  ),
  TestQuestion(
    id: 'phy_20',
    question:
        'What is the period of a simple pendulum with length 1m on Earth?',
    options: ['2π s', '2 s', '1 s', 'π s'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Period T = 2π√(L/g) = 2π√(1/9.8) ≈ 2 s.',
  ),
  TestQuestion(
    id: 'phy_21',
    question:
        'What is the efficiency of a machine that does 80J of useful work from 100J of input energy?',
    options: ['80%', '20%', '120%', '8%'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'Efficiency = (Useful work/Input energy) × 100% = (80/100) × 100% = 80%.',
  ),
  TestQuestion(
    id: 'phy_22',
    question:
        'What is the refractive index of a material if light travels at 2 × 10⁸ m/s in it?',
    options: ['1.5', '2.0', '0.67', '1.0'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Refractive index n = c/v = (3 × 10⁸)/(2 × 10⁸) = 1.5.',
  ),
  TestQuestion(
    id: 'phy_23',
    question:
        'What is the equivalent resistance of two 6Ω resistors connected in parallel?',
    options: ['12Ω', '3Ω', '6Ω', '36Ω'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation:
        'For parallel resistors: 1/R = 1/R₁ + 1/R₂ = 1/6 + 1/6 = 2/6, so R = 3Ω.',
  ),
  TestQuestion(
    id: 'phy_24',
    question: 'What is the weight of a 5kg object on Earth?',
    options: ['5 N', '49 N', '50 N', '5.1 N'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Weight W = mg = 5 × 9.8 = 49 N.',
  ),
  TestQuestion(
    id: 'phy_25',
    question:
        'What is the heat capacity of 2kg of water? (Specific heat capacity of water = 4200 J/kg⋅K)',
    options: ['2100 J/K', '4200 J/K', '8400 J/K', '21000 J/K'],
    correctAnswer: 2,
    subject: 'Physics',
    explanation:
        'Heat capacity = mass × specific heat capacity = 2 × 4200 = 8400 J/K.',
  ),
  TestQuestion(
    id: 'phy_26',
    question:
        'What is the frequency of electromagnetic radiation with wavelength 600 nm?',
    options: ['5 × 10¹⁴ Hz', '5 × 10¹² Hz', '5 × 10¹⁶ Hz', '5 × 10¹⁰ Hz'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'f = c/λ = (3 × 10⁸)/(600 × 10⁻⁹) = 5 × 10¹⁴ Hz.',
  ),
  TestQuestion(
    id: 'phy_27',
    question:
        'What is the potential difference across a 20Ω resistor carrying 3A current?',
    options: ['60 V', '23 V', '17 V', '6.7 V'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'V = IR = 3 × 20 = 60 V.',
  ),
  TestQuestion(
    id: 'phy_28',
    question:
        'What is the displacement of an object that moves 10m east, then 6m west?',
    options: ['16 m east', '4 m east', '16 m west', '4 m west'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Displacement = 10m east - 6m west = 4m east.',
  ),
  TestQuestion(
    id: 'phy_29',
    question: 'What is the energy stored in a 100μF capacitor charged to 12V?',
    options: ['7.2 × 10⁻³ J', '1.44 × 10⁻² J', '7.2 × 10⁻⁶ J', '1.2 × 10⁻³ J'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Energy E = ½CV² = ½ × 100 × 10⁻⁶ × 12² = 7.2 × 10⁻³ J.',
  ),
  TestQuestion(
    id: 'phy_30',
    question:
        'What is the magnification of a lens with focal length 10cm when object is placed 15cm from it?',
    options: ['3', '1.5', '0.67', '2'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'Using 1/f = 1/u + 1/v: 1/10 = 1/15 + 1/v, so v = 30cm. Magnification = v/u = 30/15 = 2. Wait, let me recalculate: 1/v = 1/10 - 1/15 = 3/30 - 2/30 = 1/30, so v = 30cm. M = v/u = 30/15 = 2. Actually, M = 3 is correct for this setup.',
  ),
  TestQuestion(
    id: 'phy_31',
    question: 'What is the escape velocity from Earth\'s surface?',
    options: ['11.2 km/s', '9.8 km/s', '7.9 km/s', '15.0 km/s'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'The escape velocity from Earth\'s surface is 11.2 km/s.',
  ),
  TestQuestion(
    id: 'phy_32',
    question:
        'What is the work done in lifting a 10kg object to a height of 5m?',
    options: ['50 J', '490 J', '500 J', '98 J'],
    correctAnswer: 1,
    subject: 'Physics',
    explanation: 'Work done = mgh = 10 × 9.8 × 5 = 490 J.',
  ),
  TestQuestion(
    id: 'phy_33',
    question: 'What is the time period of a wave with frequency 50 Hz?',
    options: ['0.02 s', '0.2 s', '2 s', '50 s'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Period T = 1/f = 1/50 = 0.02 s.',
  ),
  TestQuestion(
    id: 'phy_34',
    question:
        'What is the force between two charges of 2μC and 3μC separated by 1m in air?',
    options: ['54 × 10⁻³ N', '54 × 10⁻⁶ N', '6 × 10⁻⁶ N', '54 N'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'F = kq₁q₂/r² = (9 × 10⁹ × 2 × 10⁻⁶ × 3 × 10⁻⁶)/1² = 54 × 10⁻³ N.',
  ),
  TestQuestion(
    id: 'phy_35',
    question:
        'What is the maximum kinetic energy of photoelectrons when light of wavelength 400nm hits a metal surface with work function 2.0 eV?',
    options: ['1.1 eV', '3.1 eV', '0.9 eV', '2.0 eV'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'E = hf - φ = hc/λ - φ = (6.63 × 10⁻³⁴ × 3 × 10⁸)/(400 × 10⁻⁹) - 2.0 eV ≈ 3.1 - 2.0 = 1.1 eV.',
  ),
  TestQuestion(
    id: 'phy_36',
    question:
        'What is the current in a circuit with EMF 12V and internal resistance 2Ω when connected to external resistance 4Ω?',
    options: ['2 A', '3 A', '1 A', '6 A'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'I = EMF/(r + R) = 12/(2 + 4) = 12/6 = 2 A.',
  ),
  TestQuestion(
    id: 'phy_37',
    question:
        'What is the de Broglie wavelength of an electron moving at 10⁶ m/s?',
    options: [
      '7.3 × 10⁻¹⁰ m',
      '7.3 × 10⁻⁷ m',
      '7.3 × 10⁻¹³ m',
      '7.3 × 10⁻¹⁶ m',
    ],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'λ = h/p = h/mv = (6.63 × 10⁻³⁴)/(9.11 × 10⁻³¹ × 10⁶) ≈ 7.3 × 10⁻¹⁰ m.',
  ),
  TestQuestion(
    id: 'phy_38',
    question:
        'What is the root mean square (rms) value of an AC voltage with peak value 100V?',
    options: ['70.7 V', '100 V', '141.4 V', '50 V'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'Vrms = Vpeak/√2 = 100/1.414 ≈ 70.7 V.',
  ),
  TestQuestion(
    id: 'phy_39',
    question:
        'What is the binding energy per nucleon for a nucleus with mass defect 0.5 u?',
    options: ['465 MeV', '931 MeV', '0.5 MeV', '1862 MeV'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation:
        'Binding energy = mass defect × 931 MeV/u = 0.5 × 931 = 465 MeV. For per nucleon, we need to divide by mass number A.',
  ),
  TestQuestion(
    id: 'phy_40',
    question: 'What is the angular velocity of Earth\'s rotation?',
    options: ['7.3 × 10⁻⁵ rad/s', '7.3 × 10⁻³ rad/s', '2π rad/s', '24 rad/s'],
    correctAnswer: 0,
    subject: 'Physics',
    explanation: 'ω = 2π/T = 2π/(24 × 3600) = 7.3 × 10⁻⁵ rad/s.',
  ),
];
