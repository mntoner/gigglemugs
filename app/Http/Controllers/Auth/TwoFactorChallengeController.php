<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use PragmaRX\Google2FALaravel\Google2FA;
use Inertia\Inertia;

class TwoFactorChallengeController extends Controller
{
    /**
     * Display the two-factor challenge form.
     */
    public function show(Request $request)
    {
        //return view('auth.two-factor-challenge');
        return Inertia::render('Auth/TwoFactor');
    }

    /**
     * Verify the user-provided OTP.
     */
    public function store(Request $request)
    {
        $request->validate([
            'one_time_password' => ['required'],
        ]);

        // Retrieve the pending user ID from session.
        $userId = $request->session()->get('2fa:user:id');

        if (!$userId) {
            return redirect()->route('login')
                ->withErrors(['email' => __('auth.failed')]);
        }

        $user = \App\User::find($userId);

        // Resolve the Google2FA service.
        $google2fa = app(Google2FA::class);

        // Verify the OTP code.
        if ($google2fa->verifyKey($user->two_factor_secret, $request->one_time_password)) {
            // OTP valid; remove the temporary session value.
            $request->session()->forget('2fa:user:id');

            // Fully log the user in.
            Auth::login($user);

            // Regenerate the session to prevent fixation.
            $request->session()->regenerate();

            return redirect()->intended(route('dashboard', false));
        }

        return back()->withErrors(['one_time_password' => 'The provided OTP is invalid.']);
    }
} 