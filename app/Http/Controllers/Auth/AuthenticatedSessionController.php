<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Inertia\Inertia;
use Inertia\Response;

class AuthenticatedSessionController extends Controller
{
    /**
     * Display the login view.
     */
    public function create(): Response
    {
        return Inertia::render('Auth/Login', [
            'canResetPassword' => Route::has('password.request'),
            'status' => session('status'),
        ]);
    }

    /**
     * Handle an incoming authentication request.
     */
    public function store(LoginRequest $request): RedirectResponse
    {
        // Extract the login credentials.
        $credentials = $request->only('email', 'password');

        // Attempt to authenticate with the given credentials.
        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $user = Auth::user();

            // If the user has enabled 2FA, do not complete the login.
            if (!empty($user->two_factor_secret)) {
                // Store the user ID in the session for pending 2FA verification.
                $request->session()->put('2fa:user:id', $user->id);
                
                // Log the user out so that they don't have full access yet.
                Auth::logout();

                // Redirect to the two-factor challenge page.
                return redirect()->route('2fa.challenge');
            }

            // If 2FA is not enabled, complete the login.
            $request->session()->regenerate();

            return redirect()->intended(route('dashboard', false));
        }

        // If authentication fails, return with an error.
        return back()->withErrors([
            'email' => trans('auth.failed'),
        ]);
    }

    /**
     * Destroy an authenticated session.
     */
    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect('/');
    }
}
