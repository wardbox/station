export type SeasonalInsignia = {
  id: string;
  label: string;
  mark: string;
  start?: string;
  end?: string;
  weekdayOrdinal?: {
    month: number;
    weekday: number;
    ordinal: number;
  };
  href: string;
};

export const seasonalInsignia: SeasonalInsignia[] = [
  {
    id: 'black-history-month',
    label: 'Black History Month',
    mark: '✊🏿',
    start: '02-01',
    end: '02-29',
    href: 'https://en.wikipedia.org/wiki/Black_History_Month',
  },
  {
    id: 'ukraine-solidarity',
    label: 'Ukraine Solidarity Day',
    mark: '',
    start: '02-24',
    end: '02-24',
    href: 'https://en.wikipedia.org/wiki/Russian_invasion_of_Ukraine',
  },
  {
    id: 'international-womens-day',
    label: "International Women's Day",
    mark: '♀',
    start: '03-08',
    end: '03-08',
    href: 'https://en.wikipedia.org/wiki/International_Women%27s_Day',
  },
  {
    id: 'spring-equinox',
    label: 'Spring Equinox',
    mark: '☼',
    start: '03-19',
    end: '03-21',
    href: 'https://en.wikipedia.org/wiki/March_equinox',
  },
  {
    id: 'earth-day',
    label: 'Earth Day',
    mark: '♁',
    start: '04-22',
    end: '04-22',
    href: 'https://en.wikipedia.org/wiki/Earth_Day',
  },
  {
    id: 'aapi-heritage-month',
    label: 'Asian American, Native Hawaiian, and Pacific Islander Heritage Month',
    mark: '✺',
    start: '05-01',
    end: '05-31',
    href: 'https://en.wikipedia.org/wiki/Asian_American_and_Pacific_Islander_Heritage_Month',
  },
  {
    id: 'pride-month',
    label: 'Pride Month',
    mark: '',
    start: '06-01',
    end: '06-30',
    href: 'https://en.wikipedia.org/wiki/Pride_Month',
  },
  {
    id: 'juneteenth',
    label: 'Juneteenth',
    mark: '✶',
    start: '06-19',
    end: '06-19',
    href: 'https://en.wikipedia.org/wiki/Juneteenth',
  },
  {
    id: 'midsummer',
    label: 'Midsummer',
    mark: '☀',
    start: '06-20',
    end: '06-24',
    href: 'https://en.wikipedia.org/wiki/Midsummer',
  },
  {
    id: 'disability-pride-month',
    label: 'Disability Pride Month',
    mark: '◢',
    start: '07-01',
    end: '07-31',
    href: 'https://en.wikipedia.org/wiki/Disability_Pride_Month',
  },
  {
    id: 'ukraine-independence-day',
    label: 'Ukraine Independence Day',
    mark: '',
    start: '08-24',
    end: '08-24',
    href: 'https://en.wikipedia.org/wiki/Independence_Day_of_Ukraine',
  },
  {
    id: 'autumn-equinox',
    label: 'Autumn Equinox',
    mark: '◐',
    start: '09-21',
    end: '09-23',
    href: 'https://en.wikipedia.org/wiki/September_equinox',
  },
  {
    id: 'indigenous-peoples-day',
    label: "Indigenous Peoples' Day",
    mark: '',
    weekdayOrdinal: {
      month: 10,
      weekday: 1,
      ordinal: 2,
    },
    href: 'https://en.wikipedia.org/wiki/Indigenous_Peoples%27_Day',
  },
  {
    id: 'samhain',
    label: 'Samhain',
    mark: '☾',
    start: '10-31',
    end: '11-01',
    href: 'https://en.wikipedia.org/wiki/Samhain',
  },
  {
    id: 'transgender-day-of-remembrance',
    label: 'Transgender Day of Remembrance',
    mark: '⚧',
    start: '11-20',
    end: '11-20',
    href: 'https://en.wikipedia.org/wiki/Transgender_Day_of_Remembrance',
  },
  {
    id: 'human-rights-day',
    label: 'Human Rights Day',
    mark: '⚖',
    start: '12-10',
    end: '12-10',
    href: 'https://en.wikipedia.org/wiki/Human_Rights_Day',
  },
  {
    id: 'yule',
    label: 'Yule',
    mark: 'ᛃ',
    start: '12-21',
    end: '01-01',
    href: 'https://en.wikipedia.org/wiki/Yule',
  },
];
