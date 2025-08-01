import '../../domain/models/test_question.dart';

final List<TestQuestion> governmentQuestions = [
  TestQuestion(
    id: 'gov_1',
    question: 'Nigeria gained independence from Britain in which year?',
    options: ['1958', '1959', '1960', '1961'],
    correctAnswer: 2,
    subject: 'Government',
    explanation: 'Nigeria gained independence from Britain on October 1, 1960.',
  ),
  TestQuestion(
    id: 'gov_2',
    question: 'The current constitution of Nigeria was promulgated in:',
    options: ['1979', '1989', '1999', '2003'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'The 1999 Constitution of the Federal Republic of Nigeria is the current supreme law.',
  ),
  TestQuestion(
    id: 'gov_3',
    question: 'How many states are there in Nigeria?',
    options: ['30', '32', '36', '40'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Nigeria has 36 states plus the Federal Capital Territory (Abuja).',
  ),
  TestQuestion(
    id: 'gov_4',
    question:
        'The principle of separation of powers divides government into how many arms?',
    options: ['Two', 'Three', 'Four', 'Five'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Separation of powers divides government into three arms: Executive, Legislative, and Judiciary.',
  ),
  TestQuestion(
    id: 'gov_5',
    question: 'Which body is responsible for conducting elections in Nigeria?',
    options: ['EFCC', 'ICPC', 'INEC', 'NPC'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'The Independent National Electoral Commission (INEC) conducts elections in Nigeria.',
  ),
  TestQuestion(
    id: 'gov_6',
    question: 'The Nigerian National Assembly consists of:',
    options: [
      'Senate only',
      'House of Representatives only',
      'Senate and House of Representatives',
      'State Houses of Assembly',
    ],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'The National Assembly is bicameral, consisting of the Senate and House of Representatives.',
  ),
  TestQuestion(
    id: 'gov_7',
    question: 'Nigeria operates which system of government?',
    options: ['Unitary', 'Confederate', 'Federal', 'Parliamentary'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Nigeria operates a federal system of government with power shared between federal, state, and local governments.',
  ),
  TestQuestion(
    id: 'gov_8',
    question: 'The minimum age for presidential candidacy in Nigeria is:',
    options: ['30 years', '35 years', '40 years', '45 years'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'According to the 1999 Constitution, the minimum age for presidential candidacy is 35 years.',
  ),
  TestQuestion(
    id: 'gov_9',
    question: 'Local Government Areas in Nigeria are created by:',
    options: [
      'Federal Government',
      'State Governments',
      'National Assembly',
      'INEC',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Local Government Areas are created by State Governments, though the federal government recognizes them.',
  ),
  TestQuestion(
    id: 'gov_10',
    question: 'The concept of "Federal Character" in Nigeria refers to:',
    options: [
      'Presidential powers',
      'Equal representation in government',
      'State autonomy',
      'Judicial independence',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Federal Character ensures equitable representation of all states and ethnic groups in government appointments.',
  ),
  TestQuestion(
    id: 'gov_11',
    question:
        'Which military leader annulled the June 12, 1993 presidential election?',
    options: [
      'Ibrahim Babangida',
      'Sani Abacha',
      'Muhammadu Buhari',
      'Olusegun Obasanjo',
    ],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'General Ibrahim Babangida annulled the June 12, 1993 presidential election won by M.K.O. Abiola.',
  ),
  TestQuestion(
    id: 'gov_12',
    question: 'The tenure of a Nigerian President is:',
    options: ['3 years', '4 years', '5 years', '6 years'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The President serves a term of 4 years and can be re-elected for another 4-year term maximum.',
  ),
  TestQuestion(
    id: 'gov_13',
    question: 'Nigeria\'s first military coup occurred in:',
    options: ['1963', '1966', '1975', '1983'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The first military coup in Nigeria occurred on January 15, 1966.',
  ),
  TestQuestion(
    id: 'gov_14',
    question: 'The Supreme Court of Nigeria is headed by:',
    options: [
      'Chief Justice of Nigeria',
      'Attorney General',
      'President',
      'Senate President',
    ],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The Supreme Court is headed by the Chief Justice of Nigeria (CJN).',
  ),
  TestQuestion(
    id: 'gov_15',
    question: 'In Nigeria, revenue allocation is handled by:',
    options: ['CBN', 'NNPC', 'RMAFC', 'FIRS'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'The Revenue Mobilization Allocation and Fiscal Commission (RMAFC) handles revenue allocation.',
  ),
  TestQuestion(
    id: 'gov_16',
    question: 'The process of removing a President from office is called:',
    options: ['Dissolution', 'Impeachment', 'Recall', 'Suspension'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Impeachment is the constitutional process for removing a President from office for misconduct.',
  ),
  TestQuestion(
    id: 'gov_17',
    question: 'Nigeria returned to democratic rule in:',
    options: ['1998', '1999', '2000', '2001'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Nigeria returned to democratic rule on May 29, 1999, ending military rule.',
  ),
  TestQuestion(
    id: 'gov_18',
    question: 'The concept of "Checks and Balances" ensures:',
    options: [
      'Party supremacy',
      'Military control',
      'Prevention of abuse of power',
      'Economic stability',
    ],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Checks and balances prevent any one arm of government from abusing power.',
  ),
  TestQuestion(
    id: 'gov_19',
    question: 'Nigeria became a republic in:',
    options: ['1960', '1963', '1979', '1999'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Nigeria became a republic on October 1, 1963, replacing the British monarch with a Nigerian Head of State.',
  ),
  TestQuestion(
    id: 'gov_20',
    question: 'The Nigerian Senate has how many members?',
    options: ['109', '110', '360', '469'],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The Senate has 109 members: 3 senators from each of the 36 states plus 1 from FCT.',
  ),
  TestQuestion(
    id: 'gov_21',
    question:
        'Which constitutional conference recommended the federal system for Nigeria?',
    options: [
      'London Conference 1957',
      'Ibadan Conference 1950',
      'Lagos Conference 1954',
      'London Conference 1953',
    ],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The London Constitutional Conference of 1957 recommended the federal system for Nigeria.',
  ),
  TestQuestion(
    id: 'gov_22',
    question: 'The anti-corruption agency established in 2003 is:',
    options: ['EFCC', 'ICPC', 'CCB', 'CCT'],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The Economic and Financial Crimes Commission (EFCC) was established in 2003.',
  ),
  TestQuestion(
    id: 'gov_23',
    question: 'Citizenship by birth in Nigeria is acquired through:',
    options: [
      'Residence only',
      'Registration only',
      'Being born to Nigerian parents',
      'Naturalization only',
    ],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Citizenship by birth is acquired by being born to at least one Nigerian parent.',
  ),
  TestQuestion(
    id: 'gov_24',
    question: 'The highest court in each state is the:',
    options: [
      'Magistrate Court',
      'High Court',
      'Court of Appeal',
      'Supreme Court',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation: 'The High Court is the highest court in each state.',
  ),
  TestQuestion(
    id: 'gov_25',
    question: 'Public complaints against government officials are handled by:',
    options: ['Ombudsman', 'EFCC', 'Police', 'CCB'],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The Ombudsman (Public Complaints Commission) handles complaints against government officials.',
  ),
  TestQuestion(
    id: 'gov_26',
    question: 'Nigeria\'s first indigenous Governor-General was:',
    options: [
      'Nnamdi Azikiwe',
      'Tafawa Balewa',
      'Ahmadu Bello',
      'Obafemi Awolowo',
    ],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'Dr. Nnamdi Azikiwe became Nigeria\'s first indigenous Governor-General in 1960.',
  ),
  TestQuestion(
    id: 'gov_27',
    question: 'The exclusive legislative list contains subjects that:',
    options: [
      'States can legislate on',
      'Only federal government can legislate on',
      'Both federal and state can legislate on',
      'Local governments handle',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The exclusive legislative list contains subjects only the federal government can legislate on.',
  ),
  TestQuestion(
    id: 'gov_28',
    question: 'Nigeria practices which type of democracy?',
    options: [
      'Direct democracy',
      'Liberal democracy',
      'Socialist democracy',
      'People\'s democracy',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Nigeria practices liberal democracy with multi-party elections and constitutional government.',
  ),
  TestQuestion(
    id: 'gov_29',
    question: 'The Code of Conduct Bureau is responsible for:',
    options: [
      'Conducting elections',
      'Asset declaration by public officers',
      'Revenue allocation',
      'Judicial appointments',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The Code of Conduct Bureau ensures public officers declare their assets.',
  ),
  TestQuestion(
    id: 'gov_30',
    question:
        'Nigeria\'s legislature is described as bicameral because it has:',
    options: [
      'Two political parties',
      'Two sessions yearly',
      'Two chambers',
      'Two leaders',
    ],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Bicameral means having two chambers: the Senate and House of Representatives.',
  ),
  TestQuestion(
    id: 'gov_31',
    question:
        'The principle that government power comes from the people is called:',
    options: [
      'Federalism',
      'Popular sovereignty',
      'Separation of powers',
      'Rule of law',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Popular sovereignty means that government derives its authority from the consent of the people.',
  ),
  TestQuestion(
    id: 'gov_32',
    question: 'Which region was NOT part of Nigeria at independence?',
    options: [
      'Northern Region',
      'Eastern Region',
      'Western Region',
      'Mid-Western Region',
    ],
    correctAnswer: 3,
    subject: 'Government',
    explanation:
        'The Mid-Western Region was created in 1963, three years after independence.',
  ),
  TestQuestion(
    id: 'gov_33',
    question: 'The Nigerian Civil War lasted from:',
    options: ['1966-1969', '1967-1970', '1968-1971', '1969-1972'],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The Nigerian Civil War (Biafran War) lasted from 1967 to 1970.',
  ),
  TestQuestion(
    id: 'gov_34',
    question: 'Fundamental human rights in Nigeria are contained in Chapter:',
    options: ['II', 'III', 'IV', 'V'],
    correctAnswer: 2,
    subject: 'Government',
    explanation:
        'Fundamental human rights are contained in Chapter IV of the 1999 Constitution.',
  ),
  TestQuestion(
    id: 'gov_35',
    question: 'The Attorney-General of the Federation is also the:',
    options: [
      'Chief Judge',
      'Minister of Justice',
      'Senate President',
      'Chief Justice',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The Attorney-General of the Federation also serves as the Minister of Justice.',
  ),
  TestQuestion(
    id: 'gov_36',
    question: 'In Nigerian federalism, residual powers belong to:',
    options: [
      'Federal Government',
      'State Governments',
      'Local Governments',
      'All tiers equally',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Residual powers (those not listed in the constitution) belong to state governments.',
  ),
  TestQuestion(
    id: 'gov_37',
    question: 'The first military Head of State in Nigeria was:',
    options: [
      'Yakubu Gowon',
      'Johnson Aguiyi-Ironsi',
      'Murtala Mohammed',
      'Olusegun Obasanjo',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'Major General Johnson Aguiyi-Ironsi was Nigeria\'s first military Head of State in 1966.',
  ),
  TestQuestion(
    id: 'gov_38',
    question:
        'The National Youth Service Corps (NYSC) was established to promote:',
    options: [
      'Economic development',
      'National unity',
      'Educational advancement',
      'Military training',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'NYSC was established in 1973 to promote national unity and integration among Nigerian youth.',
  ),
  TestQuestion(
    id: 'gov_39',
    question: 'Political parties in Nigeria are regulated by:',
    options: ['INEC', 'Supreme Court', 'National Assembly', 'Presidency'],
    correctAnswer: 0,
    subject: 'Government',
    explanation:
        'The Independent National Electoral Commission (INEC) registers and regulates political parties.',
  ),
  TestQuestion(
    id: 'gov_40',
    question: 'The Doctrine of Necessity was invoked in Nigeria when:',
    options: [
      'Abacha died in 1998',
      'Yar\'Adua was ill in 2010',
      'Obasanjo was imprisoned',
      'Babangida stepped aside',
    ],
    correctAnswer: 1,
    subject: 'Government',
    explanation:
        'The Doctrine of Necessity was invoked in 2010 to make Goodluck Jonathan Acting President when Yar\'Adua was incapacitated.',
  ),
];
