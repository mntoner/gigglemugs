<template>
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <!-- Grass base -->
        <path 
            d="M 30 100
               Q 45 95 50 100
               Q 55 95 70 100
               L 70 100
               L 30 100"
            fill="#9ACD32"
        />
        <!-- Tree shadow -->
        <path
            d="M 30 85
               Q 50 95 70 85
               Q 50 100 30 85 Z"
            fill="rgba(0, 0, 0, 0.5)"
        />
        <!-- Tree trunk -->
        <path 
            d="M 45 70 L 45 90 L 55 90 L 55 70 Z"
            fill="#8B4513"
        />
        <!-- Tree foliage -->
        <path
            d="M 50 10
               Q 70 15 80 40
               Q 90 60 50 70
               Q 10 60 20 40
               Q 30 15 50 10 Z"
            fill="#228B22"
        />
    </svg>
</template>
