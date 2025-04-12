<script setup>
import { ref, computed, onMounted } from 'vue';
import { Head, usePage } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'; // Import AuthenticatedLayout
import AppHeader from '@/Components/AppHeader.vue'; // Keep AppHeader for guest view
// Footer import removed
import MarkdownIt from 'markdown-it';

const page = usePage();
const user = computed(() => page.props.auth.user);
// Add dark mode state for consistency between authenticated and guest views
const isDark = ref(false);

// When the component is mounted, load the saved dark mode preference
onMounted(() => {
  if (localStorage.getItem('isDark') === 'true') {
    isDark.value = true;
    document.documentElement.classList.add('dark');
  }
});

const props = defineProps({
  location: {
    type: Object,
    required: true,
  },
});

const md = new MarkdownIt();
const mapContainer = ref(null); // Ref for the map container div

// Compute the featured image URL from the details JSON
const featuredImage = computed(() => {
    // Assuming details is parsed JSON. If it's a string, parse it first.
    let detailsData = props.location.details;
    if (typeof detailsData === 'string') {
        try {
            detailsData = JSON.parse(detailsData);
        } catch (e) {
            console.error("Error parsing location details JSON:", e);
            return null; // Or a default image path
        }
    }
    // Ensure the path starts with /storage/ if it's a relative path from public/storage
    let imagePath = detailsData?.featured_image;
    if (imagePath && !imagePath.startsWith('/')) {
        imagePath = '/storage/' + imagePath; // Adjust if your storage link points elsewhere
    }
    return imagePath;
});


// Compute the rendered HTML from the markdown description
const renderedMarkdown = computed(() => {
    // Assuming details is parsed JSON. If it's a string, parse it first.
     let detailsData = props.location.details;
    if (typeof detailsData === 'string') {
        try {
            detailsData = JSON.parse(detailsData);
        } catch (e) {
            console.error("Error parsing location details JSON:", e);
            return '<p>Error loading description.</p>';
        }
    }
  const description = detailsData?.description || 'No description available.';
  return md.render(description);
});

// Placeholder for map initialization logic
const initMap = () => {
  if (!mapContainer.value) return;
  if (typeof google === 'undefined' || !google.maps) {
      console.warn("Google Maps API not loaded yet.");
      // Optionally, retry or inform the user
      mapContainer.value.innerHTML = '<p class="text-center p-4">Could not load Google Maps.</p>';
      return;
  }

  const position = { lat: parseFloat(props.location.latitude), lng: parseFloat(props.location.longitude) };
  const mapOptions = {
    center: position,
    zoom: 15,
    mapId: 'GIGGLEMUGS_LOCATION_MAP' // Optional: Add a Map ID for Advanced Markers & styling
  };
  const map = new google.maps.Map(mapContainer.value, mapOptions);

  // Use AdvancedMarkerElement
  new google.maps.marker.AdvancedMarkerElement({
    position: position,
    map: map,
    title: props.location.name,
  });
};

onMounted(() => {
    // Check if Google Maps API is loaded, if not, wait for it.
    // This basic check assumes the script might load after the component mounts.
    // A more robust solution might involve a global state or event bus.
    if (typeof google !== 'undefined' && google.maps) {
        initMap();
    } else {
        // Poll or use a callback if your script loader supports it
        const intervalId = setInterval(() => {
            if (typeof google !== 'undefined' && google.maps) {
                clearInterval(intervalId);
                initMap();
            }
        }, 500); // Check every 500ms
         // Clear interval after some time to prevent infinite loop if script fails
        setTimeout(() => clearInterval(intervalId), 10000);
    }
});

</script>

<template>
    <Head :title="location.name" />

    <!-- Authenticated View -->
    <AuthenticatedLayout v-if="user">
         <template #header>
            <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
                {{ location.name }}
            </h2>
        </template>

        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                 <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 text-gray-900 dark:text-gray-100">
                        <!-- Featured Image -->
                        <div v-if="featuredImage" class="mb-6">
                          <img :src="featuredImage" :alt="location.name" class="w-full h-auto object-cover rounded-lg shadow-md max-h-96">
                        </div>
                        <div v-else class="mb-6 h-64 bg-gray-200 dark:bg-gray-700 rounded-lg shadow-md flex items-center justify-center">
                            <span class="text-gray-500 dark:text-gray-400">No image available</span>
                        </div>

                        <!-- Description (Markdown) -->
                        <div class="prose dark:prose-invert max-w-none mb-8" v-html="renderedMarkdown">
                        </div>

                        <!-- Google Map Placeholder -->
                        <div class="mb-8">
                          <h2 class="text-2xl font-semibold mb-4">Location Map</h2>
                          <div ref="mapContainer" class="w-full h-96 bg-gray-300 dark:bg-gray-600 rounded-lg shadow-md">
                            <!-- Google Map will be initialized here -->
                            Map Placeholder
                          </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>

    <!-- Guest View -->
    <div v-else :class="{ dark: isDark }">
        <AppHeader />
        <!-- Add header to match authenticated layout -->
        <header class="bg-white dark:bg-gray-800 shadow">
            <div class="max-w-7xl mx-auto px-4 py-6 sm:px-6 lg:px-8">
                <h2 class="font-semibold text-xl text-gray-800 dark:text-gray-200 leading-tight">
                    {{ location.name }}
                </h2>
            </div>
        </header>
        
        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6 text-gray-900 dark:text-gray-100">
                        <!-- Featured Image -->
                        <div v-if="featuredImage" class="mb-6">
                          <img :src="featuredImage" :alt="location.name" class="w-full h-auto object-cover rounded-lg shadow-md max-h-96">
                        </div>
                        <div v-else class="mb-6 h-64 bg-gray-200 dark:bg-gray-700 rounded-lg shadow-md flex items-center justify-center">
                            <span class="text-gray-500 dark:text-gray-400">No image available</span>
                        </div>


                        <!-- Description (Markdown) -->
                        <div class="prose dark:prose-invert max-w-none mb-8" v-html="renderedMarkdown">
                        </div>

                        <!-- Google Map Placeholder -->
                        <div class="mb-8">
                          <h2 class="text-2xl font-semibold mb-4">Location Map</h2>
                          <div ref="mapContainer" class="w-full h-96 bg-gray-300 dark:bg-gray-600 rounded-lg shadow-md">
                            <!-- Google Map will be initialized here -->
                            Map Placeholder
                          </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Consider adding a guest footer here if needed -->
    </div>
</template>

<style>
/* Add styles for prose plugin if needed, or rely on Tailwind typography */
/* Ensure prose styles work well in dark mode if using AuthenticatedLayout */
.dark .prose {
    /* Example: Adjust prose colors for dark mode */
    /* color: theme('colors.gray.300'); */
}
.prose img {
    /* Example style override */
    margin-top: 1em;
    margin-bottom: 1em;
}
</style>