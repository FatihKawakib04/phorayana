import { ref, computed } from 'vue'
import { get, set } from 'idb-keyval'
import type { Database } from '~/types/database.types'

export function useSavedPlaces() {
  const supabase = useSupabaseClient<Database>()
  const user = useSupabaseUser()

  const userId = computed(() => user.value?.id || user.value?.sub)
  const savedPlaces = ref<any[]>([])
  const isLoadingPlaces = ref(false)
  const newPlaceName = ref('')
  const errorMessage = ref('')

  const fetchSavedPlaces = async () => {
    if (!userId.value) return
    isLoadingPlaces.value = true
    try {
      if (import.meta.client && !navigator.onLine) {
        // Offline fallback cache read
        const cached = await get('wpy_saved_places')
        if (Array.isArray(cached)) {
          savedPlaces.value = cached
        }
        return
      }

      const { data, error } = await supabase
        .from('saved_places')
        .select('*')
        .eq('user_id', userId.value)
        .order('created_at', { ascending: true })

      if (error) throw error

      savedPlaces.value = data ?? []
      if (import.meta.client) {
        await set('wpy_saved_places', JSON.parse(JSON.stringify(savedPlaces.value)))
      }
    } catch (err: any) {
      errorMessage.value = err.message || 'Gagal memuat lokasi favorit.'
      console.error('Error fetching saved places:', err)
      
      // Fallback cache read on database error
      if (import.meta.client) {
        const cached = await get('wpy_saved_places')
        if (Array.isArray(cached)) {
          savedPlaces.value = cached
        }
      }
    } finally {
      isLoadingPlaces.value = false
    }
  }

  const addSavedPlace = async (coords: { lat: number; lng: number }) => {
    if (!newPlaceName.value.trim() || !userId.value) return
    isLoadingPlaces.value = true
    errorMessage.value = ''
    try {
      const payload = {
        user_id: userId.value,
        place_name: newPlaceName.value.trim(),
        latitude: coords.lat,
        longitude: coords.lng
      }

      const { data, error } = await supabase
        .from('saved_places')
        .insert(payload)
        .select()
        .single()

      if (error) throw error

      savedPlaces.value.push(data)
      newPlaceName.value = ''
      if (import.meta.client) {
        await set('wpy_saved_places', JSON.parse(JSON.stringify(savedPlaces.value)))
      }
    } catch (err: any) {
      errorMessage.value = err.message || 'Gagal menambahkan lokasi.'
      console.error('Error adding saved place:', err)
    } finally {
      isLoadingPlaces.value = false
    }
  }

  const deleteSavedPlace = async (id: number) => {
    if (!userId.value) return
    isLoadingPlaces.value = true
    errorMessage.value = ''
    try {
      const { error } = await supabase
        .from('saved_places')
        .delete()
        .eq('id', id)
        .eq('user_id', userId.value)

      if (error) throw error

      savedPlaces.value = savedPlaces.value.filter(place => place.id !== id)
      if (import.meta.client) {
        await set('wpy_saved_places', JSON.parse(JSON.stringify(savedPlaces.value)))
      }
    } catch (err: any) {
      errorMessage.value = err.message || 'Gagal menghapus lokasi.'
      console.error('Error deleting saved place:', err)
    } finally {
      isLoadingPlaces.value = false
    }
  }

  return {
    savedPlaces,
    isLoadingPlaces,
    newPlaceName,
    errorMessage,
    fetchSavedPlaces,
    addSavedPlace,
    deleteSavedPlace
  }
}
