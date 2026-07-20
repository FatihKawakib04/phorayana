/**
 * Utility to map local dates to regional events and national holidays
 * (especially Jabodetabek/Bogor/Jakarta).
 */
export const detectRegionalEvent = (dateInput: string | Date | null): string | null => {
  if (!dateInput) return null
  const date = new Date(dateInput)
  if (isNaN(date.getTime())) return null

  // Format as MM-DD
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const day = date.getDate().toString().padStart(2, '0')
  const mmdd = `${month}-${day}`

  const events: Record<string, string> = {
    '01-01': 'Libur Nasional - Tahun Baru',
    '05-01': 'Libur Nasional - Hari Buruh',
    '06-01': 'Libur Nasional - Hari Lahir Pancasila',
    '06-03': 'HUT Kota Bogor',
    '06-22': 'HUT Kota Jakarta',
    '08-17': 'Libur Nasional - Hari Kemerdekaan RI',
    '12-25': 'Libur Nasional - Hari Natal'
  }

  return events[mmdd] || null
}
