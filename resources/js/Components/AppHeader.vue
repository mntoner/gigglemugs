<script setup>
import { Link } from '@inertiajs/vue3';
import ApplicationLogo from '@/Components/ApplicationLogo.vue'; // Assuming you want the logo

// Define props if needed in the future, e.g., for canRegister
// defineProps({
//     canLogin: Boolean,
//     canRegister: Boolean,
// });
</script>

<template>
    <header class="bg-white dark:bg-gray-800 shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex">
                    <!-- Logo -->
                    <div class="shrink-0 flex items-center">
                        <Link :href="route('dashboard')"> <!-- Or link to '/' if dashboard isn't always the target -->
                            <ApplicationLogo
                                class="block h-9 w-auto fill-current text-gray-800 dark:text-gray-200"
                            />
                        </Link>
                    </div>

                    <!-- Navigation Links (Optional - Add if needed for other pages) -->
                    <!-- <div class="hidden space-x-8 sm:-my-px sm:ms-10 sm:flex">
                        <NavLink :href="route('dashboard')" :active="route().current('dashboard')">
                            Dashboard
                        </NavLink>
                    </div> -->
                </div>

                <!-- Login/Register/Dashboard Links -->
                <div class="hidden sm:flex sm:items-center sm:ms-6">
                     <nav class="-mx-3 flex flex-1 justify-end">
                        <Link
                            v-if="$page.props.auth.user"
                            :href="route('dashboard')"
                            class="rounded-md px-3 py-2 text-black ring-1 ring-transparent transition hover:text-black/70 focus:outline-none focus-visible:ring-[#FF2D20] dark:text-white dark:hover:text-white/80 dark:focus-visible:ring-white"
                        >
                            Dashboard
                        </Link>

                        <template v-else>
                            <Link
                                :href="route('login')"
                                class="rounded-md px-3 py-2 text-black ring-1 ring-transparent transition hover:text-black/70 focus:outline-none focus-visible:ring-[#FF2D20] dark:text-white dark:hover:text-white/80 dark:focus-visible:ring-white"
                            >
                                Log in
                            </Link>

                            <Link
                                :href="route('register')"
                                class="rounded-md px-3 py-2 text-black ring-1 ring-transparent transition hover:text-black/70 focus:outline-none focus-visible:ring-[#FF2D20] dark:text-white dark:hover:text-white/80 dark:focus-visible:ring-white"
                            >
                                Register
                            </Link>
                            <!-- Note: We always show Register here as canRegister isn't globally shared -->
                            <!-- If canRegister logic is needed, pass it as a prop -->
                        </template>
                    </nav>
                </div>

                 <!-- Hamburger (for mobile - adapt from AuthenticatedLayout if needed) -->
                 <div class="-me-2 flex items-center sm:hidden">
                     <!-- Mobile menu button placeholder -->
                      <button class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 dark:text-gray-500 hover:text-gray-500 dark:hover:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-900 focus:outline-none focus:bg-gray-100 dark:focus:bg-gray-900 focus:text-gray-500 dark:focus:text-gray-400 transition duration-150 ease-in-out">
                        <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" /> <!-- Basic hamburger icon -->
                        </svg>
                    </button>
                 </div>
            </div>
        </div>

         <!-- Responsive Navigation Menu (for mobile - adapt from AuthenticatedLayout if needed) -->
         <!-- Add mobile menu logic here if needed -->
         <div class="hidden sm:hidden">
             <div class="pt-2 pb-3 space-y-1">
                 <!-- Mobile links placeholder -->
             </div>
         </div>
    </header>
</template>