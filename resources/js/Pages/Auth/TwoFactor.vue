<script setup>
import Checkbox from '@/Components/Checkbox.vue';
import GuestLayout from '@/Layouts/GuestLayout.vue';
import InputError from '@/Components/InputError.vue';
import InputLabel from '@/Components/InputLabel.vue';
import PrimaryButton from '@/Components/PrimaryButton.vue';
import TextInput from '@/Components/TextInput.vue';
import { Head, Link, useForm } from '@inertiajs/vue3';

defineProps({
    canResetPassword: {
        type: Boolean,
    },
    status: {
        type: String,
    },
});

const form = useForm({
    one_time_password: '',
});

const submit = () => {
    form.post(route('2fa.challenge.store'), {
        onFinish: () => form.reset('one_time_password'),
    });
};

</script>

<template>
    <GuestLayout>
        <Head title="Two-Factor Authentication" />

        <h1 class="text-2xl font-bold mb-4">Two-Factor Authentication</h1>
        <p class="mb-6">Please enter the code from your authenticator app to continue.</p>

        <form @submit.prevent="submit">
            <InputLabel for="one_time_password" :value="'One-Time Password'" />
            <TextInput 
              id="one_time_password"
              type="text"
              class="mt-1 block w-full"
              v-model="form.one_time_password"
              required
              autofocus
            />
            <InputError :message="form.errors.one_time_password" class="mt-2" />

            <PrimaryButton class="mt-4" :disabled="form.processing">
                Verify
            </PrimaryButton>
        </form>
    </GuestLayout>
</template>
