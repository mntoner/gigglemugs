<script setup>
import { Link } from '@inertiajs/vue3';
import ApplicationLogo from '@/Components/ApplicationLogo.vue'; // Assuming you want the logo




</script>

<template>
    <header class="dark:bg-gray-800 shadow relative" style="background-image: url('/images/sandstone-texture.svg'); ">
        <!-- Semi-transparent overlay for better text visibility -->
        <!-- <div class="absolute inset-0 bg-white/30 dark:bg-gray-800/70"></div> -->
        
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">

            
            <div class="grid grid-cols-12 gap-4">
                <div class="col-span-2">
                    <img src="/images/palin_trans.png" style="height: 146px" class="w-auto" />
                </div>
                <div class="col-span-8 text-center">
                    <div class="brand-heading cinzel-decorative-bold ">~ Gigglemugs ~</div>
                    <div class="brand-subheading cinzel-decorative-regular">Guide to Chester</div>
                    <div class="brand-subheading_2 cinzel-decorative-bold">What have the Romans ever done for Chester? <a class="heading-link" href="">Find out here</a></div>
                </div>
                <div class="col-span-2">
                    <img src="/images/solder_trans.png" style="height: 140px" class="w-auto float-right" />
                </div>
            </div>




            <div class="flex justify-between h-16">


                <!-- <div class="flex">

                    <div class="shrink-0 flex items-center">
                        <Link :href="route('dashboard')"> 
                            <ApplicationLogo
                                class="block h-9 w-auto fill-current text-gray-800 dark:text-gray-200"
                            />
                        </Link>
                    </div>


                    <div class="hidden space-x-8 sm:-my-px sm:ms-10 sm:flex">
                        <NavLink :href="route('dashboard')" :active="route().current('dashboard')">
                            Dashboard
                        </NavLink>
                    </div>
                </div> -->

                <!-- Login/Register/Dashboard Links -->
                <!-- <div class="hidden sm:flex sm:items-center sm:ms-6">
                     <nav class="-mx-3 flex flex-1 justify-end">
                        <Link
                            v-if="$page.props.auth.user"
                            :href="route('dashboard')"
                            class="rounded-md px-3 py-2 ring-1 ring-transparent transition focus:outline-none focus-visible:ring-[#FF2D20] text-white dark:focus-visible:ring-white"
                        >
                            Dashboard
                        </Link>

                        <template v-else>
                            <Link
                                :href="route('login')"
                                class="rounded-md px-3 py-2  ring-1 ring-transparent transition  focus:outline-none focus-visible:ring-[#FF2D20] text-white  dark:focus-visible:ring-white"
                            >
                                Log in
                            </Link>

                            <Link
                                :href="route('register')"
                                class="rounded-md px-3 py-2 ring-1 ring-transparent transition  focus:outline-none focus-visible:ring-[#FF2D20] text-white  dark:focus-visible:ring-white"
                            >
                                Register
                            </Link>

                        </template>
                    </nav>
                </div> -->

                 <!-- Hamburger (for mobile - adapt from AuthenticatedLayout if needed) -->
                 <!-- <div class="-me-2 flex items-center sm:hidden">
                     
                      <button class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 dark:text-gray-500 hover:text-gray-500 dark:hover:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-900 focus:outline-none focus:bg-gray-100 dark:focus:bg-gray-900 focus:text-gray-500 dark:focus:text-gray-400 transition duration-150 ease-in-out">
                        <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                        </svg>
                    </button>
                 </div> -->
            </div>
        </div>

         <!-- Responsive Navigation Menu (for mobile - adapt from AuthenticatedLayout if needed) -->
         <div class="hidden sm:hidden">
             <div class="pt-2 pb-3 space-y-1">
                 <!-- Mobile links placeholder -->
             </div>
         </div>
    </header>
</template>