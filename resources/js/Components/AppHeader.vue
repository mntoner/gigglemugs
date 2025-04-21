<script setup>
// import { Link } from '@inertiajs/vue3';
// import ApplicationLogo from '@/Components/ApplicationLogo.vue'; // Assuming you want the logo

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

        </div>


    </header>
</template>