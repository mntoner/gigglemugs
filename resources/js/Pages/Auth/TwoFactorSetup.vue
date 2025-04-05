<script setup>
import { Head } from '@inertiajs/vue3';
import { router } from '@inertiajs/vue3';
import { useForm } from '@inertiajs/vue3';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputLabel from '@/Components/InputLabel.vue';
import InputError from '@/Components/InputError.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';

// Accept props coming from the server (make sure your controller passes these)
const props = defineProps({
  canResetPassword: Boolean, // still available if needed elsewhere
  status: String,
  QR_Image: String, // pass the QR HTML string (e.g. from a controller using QR code generation)
  secret: String,
});

// Create a form object to manage the one_time_password input and errors via Inertia.
const enableForm = useForm({
  one_time_password: '',
});

// Method to handle enabling two factor authentication.
function enable2FA() {
  enableForm.post(route('2fa.enable'), {
    preserveScroll: true,
    onSuccess: () => {
      enableForm.reset();
    },
  });
}

// Method to handle disabling two factor authentication.
function disable2FA() {
  router.post(route('2fa.disable'), {}, {
    preserveScroll: true,
  });
}
</script>

<template>
  <GuestLayout>
    <Head title="Two Factor Authentication Setup" />
    <h1 class="text-2xl font-bold mb-4">Two Factor Authentication Setup</h1>
    
    <p class="mb-2">Scan this QR code with your authenticator app:</p>
    <!-- Render the QR code HTML -->
    
    <div v-html="QR_Image" class="mb-4"></div>

    <p class="mb-4">
      If you cannot scan the QR code, use this secret key authenticator app: 
      <strong>{{ secret }}</strong>
    </p>

    <!-- Form to Enable 2FA -->
    <form @submit.prevent="enable2FA" class="mb-6">
      <InputLabel for="one_time_password" value="Enter the code from your authentication app:" />
      <TextInput 
        id="one_time_password"
        v-model="enableForm.one_time_password" 
        type="text" 
        required 
        autofocus 
        class="mt-1 block w-full"
      />
      <InputError :message="enableForm.errors.one_time_password" class="mt-2" />
      <div class="mt-4">
        <PrimaryButton>Enable 2FA</PrimaryButton>
      </div>
    </form>

    <hr class="my-6">

    <!-- Form to Disable 2FA -->
    <form @submit.prevent="disable2FA">
      <PrimaryButton type="submit" class="bg-red-500 hover:bg-red-700">
        Disable 2FA
      </PrimaryButton>
    </form>

    <!-- Display status message, if any -->
    <div v-if="status" class="mt-4 text-green-600">
      {{ status }}
    </div>
  </GuestLayout>
</template>
