<script setup>
import { ref, computed, onMounted } from 'vue';
import { Head, usePage } from '@inertiajs/vue3';
import AppHeader from '@/Components/AppHeader.vue'; // Keep AppHeader for guest view
import Footer from '@/Components/Footer.vue'; // Import Footer component
import LocationNavPanel from '@/Components/LocationNavPanel.vue'; // Import the new nav panel
import MarkdownIt from 'markdown-it';

const page = usePage();
const user = computed(() => page.props.auth.user);

const props = defineProps({
  location: {
    type: Object,
    required: true,
  },
});

// Add modal state for the map
const showMapModal = ref(false);

// Function to toggle the map modal
const toggleMapModal = () => {
  showMapModal.value = !showMapModal.value;
  
  // Initialize map when modal is opened
  if (showMapModal.value) {
    // Wait for DOM to update before initializing the map
    setTimeout(() => {
      initMap();
    }, 100);
  }
};

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

// Map initialization logic - now only runs when modal is opened
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


</script>

<template>
    <Head :title="location.name" />

    <div>
        <AppHeader />

        <div class='flex justify-center max-w-lg flex-col mx-auto' style="max-width:1200px">

            <h1 class="mt-5 location-heading eb-garamond-bold  text-center">
                {{ location.name }}
            </h1>

            <!-- Main content area with Flexbox for sidebar -->
            <div class="flex min-h-screen items-start"> <!-- Added items-start -->

                <!-- Sidebar Container: Holds Nav Panel and Map Button -->
                <div class="flex-shrink-0"> <!-- Wrapper is a non-shrinking flex item -->
                    <!-- Navigation Panel -->
                    <LocationNavPanel v-if="location.city" :city="location.city" />

                    <!-- Map Link -->
                    <div class="px-4 py-3 google-map-thumb mt-auto" @click="toggleMapModal" style="cursor: pointer;"> <!-- Add mt-auto to push to bottom -->
                        <button
                            @click="toggleMapModal"
                            class="google-map-button w-full px-4 py-2 text-amber-800 rounded-md flex items-center justify-center space-x-2 transition"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
                            </svg>
                            <span>View Google Map</span>
                        </button>
                    </div>
                </div>

                <!-- Page Content -->
                <div class="flex-grow overflow-y-auto"> <!-- Content takes remaining space -->
                    <div class="max-w-7xl mx-auto px-8 py-6"> <!-- Added padding -->
                        <div class="bg-white dark:bg-gray-800 overflow-hidden shadow-sm sm:rounded-lg">
                            <div class="text-gray-900 dark:text-gray-100">
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

                                <!-- Google Map section removed from here -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Map Modal -->
            <div v-if="showMapModal" class="fixed inset-0 z-50 overflow-auto bg-black bg-opacity-50 flex items-center justify-center p-4">
                <div class="bg-white dark:bg-gray-800 w-full max-w-4xl rounded-lg shadow-xl">
                    <div class="p-6">
                        <div class="flex justify-between items-center mb-4">
                            <h2 class="text-2xl font-semibold text-gray-900 dark:text-gray-100">Location Map</h2>
                            <button @click="toggleMapModal" class="p-2 rounded-md hover:bg-gray-200 dark:hover:bg-gray-700 transition">
                                <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6 text-gray-600 dark:text-gray-300" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>
                        <div ref="mapContainer" class="w-full h-96 bg-gray-300 dark:bg-gray-600 rounded-lg">
                            <!-- Google Map will be initialized here when modal opens -->
                            <div class="w-full h-full flex items-center justify-center">
                                <p class="text-gray-500 dark:text-gray-400">Loading map...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

        <Footer />
    </div>
</template>

<style>
/* Add styles for prose plugin if needed, or rely on Tailwind typography */
/* Ensure prose styles work well in dark mode if using AuthenticatedLayout */
.prose img {
    /* Example style override */
    margin-top: 1em;
    margin-bottom: 1em;
}

/* Add styles for the map modal */
.map-modal-enter-active,
.map-modal-leave-active {
    transition: opacity 0.3s;
}
.map-modal-enter-from,
.map-modal-leave-to {
    opacity: 0;
}
</style>