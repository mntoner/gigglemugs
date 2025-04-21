<script setup>
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import { Link, usePage } from '@inertiajs/vue3';
// Removed incorrect import for slugify

const props = defineProps({
  city: {
    type: String,
    required: true,
  },
});

const locations = ref([]);
const isLoading = ref(true);
const error = ref(null);
const page = usePage();

// Computed property to get the current location ID from the page props/URL
// Adjust this based on how the location ID is available in the main page context
const currentLocationId = computed(() => {
    // Example: Assuming the full location object is passed via Inertia props
    // Or potentially extract from page.url if the ID is in the URL
    return page.props.location?.id;
});

// Function to remove city name from location name
const formatLocationName = (locationName) => {
  // Check if the location name contains the city name
  if (locationName && props.city && locationName.includes(props.city)) {
    // Remove the city name and any separators (like comma, hyphen) and trim spaces
    return locationName.replace(new RegExp(`${props.city}\\s*[,-]?\\s*`, 'i'), '').trim();
  }
  return locationName;
};

const fetchLocations = async () => {
  isLoading.value = true;
  error.value = null;
  try {
    const response = await axios.get(`/locations/city/${encodeURIComponent(props.city)}`);
    locations.value = response.data;
  } catch (err) {
    console.error("Error fetching locations:", err);
    error.value = "Failed to load locations.";
  } finally {
    isLoading.value = false;
  }
};

// Generate the URL for a location link
const getLocationUrl = (location) => {
  // Use the existing route helper if available, otherwise construct the URL manually
  // Assuming route('location.show', { location: location.id, location_name: slugify(location.name) }) structure
  // For simplicity, constructing manually here. Replace with route() if preferred.
  // Let's assume the route helper 'route' is available globally via Ziggy
  // If not, we'll need to adjust this.
  // We need to ensure slugify is available here. If it's a PHP function,
  // we might need to pass the slug from the controller or implement slugify in JS.
  // For now, assuming a JS slugify function.
  // If Utilities.js doesn't exist, this will fail. Let's create a simple JS slugify for now.
   const jsSlugify = (text) => {
        return text.toString().toLowerCase()
            .replace(/\s+/g, '-')           // Replace spaces with -
            .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
            .replace(/\-\-+/g, '-')         // Replace multiple - with single -
            .replace(/^-+/, '')             // Trim - from start of text
            .replace(/-+$/, '');            // Trim - from end of text
    };
  return route('location.show', { location: location.id, location_name: jsSlugify(location.name) });
};


onMounted(() => {
  if (props.city) {
    fetchLocations();
  } else {
      isLoading.value = false;
      error.value = "City not provided.";
  }
});
</script>

<template>
  <div class="nav-panel-container w-64 p-4 h-full overflow-y-auto flex-shrink-0" style="padding-top: 160px;">
    <!-- <h3 class="text-lg font-semibold mb-4 text-gray-800 dark:text-gray-200">Locations in {{ city }}</h3> -->
    <div v-if="isLoading">Loading...</div>
    <div v-else-if="error" class="text-red-500">{{ error }}</div>
    <ul v-else-if="locations.length > 0" class="space-y-2">
      <li v-for="location in locations" :key="location.id">
        <Link
          :href="getLocationUrl(location)"
          style="font-family: 'EB Garamond';font-weight: 700;font-size: 1.2em;"
          :class="[
            'block px-3 py-1 rounded-md text-sm  transition-colors duration-150 ease-in-out',
            location.id === currentLocationId
                ? 'bg-red-700 text-white dark:bg-red-800' // Active link style - brick red color
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700' // Inactive link style
          ]"
        >
          {{ formatLocationName(location.name) }}
        </Link>
      </li>
    </ul>
    <div v-else class="text-gray-500 dark:text-gray-400">No locations found in this city.</div>
  </div>
</template>

<style scoped>
/* Add any specific styles for the nav panel here if needed */
.nav-panel-container {
  background-image: url('/images/romans_go_home_bg_trans.gif');
  background-repeat: no-repeat;
  background-size: cover;
  background-position: top center; /* Changed to 'top center' to always show the top */
  min-height: 130%; /* Set minimum height to 130% */
}
</style>