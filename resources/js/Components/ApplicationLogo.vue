<template>
    <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
        <defs>
            <!-- Filter for sandstone texture -->
            <filter id="sandstoneTexture">
                <feTurbulence type="fractalNoise" baseFrequency="0.05" numOctaves="3" result="noise"/>
                <feDiffuseLighting in="noise" lighting-color="#D2B48C" surfaceScale="2" result="light">
                    <feDistantLight azimuth="45" elevation="60"/>
                </feDiffuseLighting>
                <feComposite operator="in" in2="SourceGraphic" result="textured"/>
            </filter>

            <!-- Filter for etched effect (displacement) -->
            <filter id="etchEffect">
                <feTurbulence type="fractalNoise" baseFrequency="0.1" numOctaves="1" result="turbulence"/>
                <feDisplacementMap in2="turbulence" in="SourceGraphic" scale="1.5" xChannelSelector="R" yChannelSelector="G"/>
            </filter>

             <!-- Combined Filter -->
            <filter id="romanEtching" x="-10%" y="-10%" width="120%" height="120%">
                <!-- Base Texture -->
                <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="2" seed="10" result="textureNoise"/>
                <feDiffuseLighting in="textureNoise" lighting-color="#C19A6B" surfaceScale="1.5" result="textureLight">
                    <feDistantLight azimuth="45" elevation="50"/>
                </feDiffuseLighting>
                 <feComposite operator="arithmetic" k1="1" k2="0" k3="0" k4="0" in="textureLight" in2="SourceAlpha" result="texturedShape"/>

                <!-- Etch Displacement -->
                 <feTurbulence type="turbulence" baseFrequency="0.2" numOctaves="2" seed="20" result="etchNoise"/>
                 <feDisplacementMap in="SourceGraphic" in2="etchNoise" scale="1" xChannelSelector="R" yChannelSelector="A" result="displaced"/>

                 <!-- Combine texture and displacement -->
                 <feBlend mode="multiply" in="texturedShape" in2="displaced"/>
            </filter>
        </defs>

        <!-- Optional Wall Background -->
        <rect x="0" y="0" width="100" height="100" fill="#D2B48C" filter="url(#sandstoneTexture)" />


        <!-- Rotated Face Group with Etching Filter -->
        <g transform="rotate(-20 50 50)" filter="url(#romanEtching)">
            <!-- Face (less round, sandstone color) -->
            <ellipse cx="50" cy="55" rx="48" ry="42" fill="#E0CBA8" stroke="#8B4513" stroke-width="1.5"/>

            <!-- Eyes (simple etched lines) -->
            <path d="M 30 40 Q 35 35 40 40" stroke="#8B4513" stroke-width="2" fill="none"/>
            <path d="M 60 42 Q 65 37 70 42" stroke="#8B4513" stroke-width="2" fill="none"/>
            <!-- No pupils for simpler etched look -->

            <!-- Laughing Mouth (bigger lips, darker sandstone color) -->
            <path d="M 25 68 Q 50 95 75 68 Q 50 85 25 68" fill="#A0522D" stroke="#8B4513" stroke-width="1.5"/>

            <!-- No blush marks for etched style -->
        </g>
    </svg>
</template>
