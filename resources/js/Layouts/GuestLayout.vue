<script setup>
import AppHeader from '@/Components/AppHeader.vue'; // Import the header
import { Link } from '@inertiajs/vue3';
</script>

<template>
    <div class="min-h-screen bg-gray-100 dark:bg-gray-900">
        <AppHeader />

        <!-- Page Content -->
        <main>
            <slot />
        </main>
    </div>
</template>
