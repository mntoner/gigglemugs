<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use PragmaRX\Google2FALaravel\Google2FA;
use Illuminate\Support\Facades\Auth;
use Inertia\Inertia;

class TwoFactorAuthenticationController extends Controller
{
    /**
     * Display the QR code and 2FA setup form.
     */
    public function show(Request $request)
    {
        $user = $request->user();
        $google2fa = app(Google2FA::class);

        // If the user doesn't have a 2FA secret, generate and persist it.
        if (!$user->two_factor_secret) {
            $secret = $google2fa->generateSecretKey();
            $user->two_factor_secret = $secret;
            $user->save();
        } else {
            $secret = $user->two_factor_secret;
        }

        // Generate the QR code image inline.
        $QR_Image = $google2fa->getQRCodeInline(
            config('app.name'),
            $user->email,
            $secret
        );

        //return view('google2fa.index', compact('secret', 'QR_Image'));
        return Inertia::render('Auth/TwoFactorSetup', [
            'secret'   => $secret,
            'QR_Image' => $QR_Image,
        ]);
    }

    /**
     * Enable two factor authentication after verifying the OTP.
     */
    public function enable(Request $request)
    {
        $request->validate([
            'one_time_password' => 'required',
        ]);

        $user = $request->user();
        $google2fa = app(Google2FA::class);

        // No need to generate a new secret here, since it is
        // now persisted from the show() method.
        if ($google2fa->verifyKey($user->two_factor_secret, $request->one_time_password)) {
            //return redirect()->back()->with('status', 'Two factor authentication enabled');
            return redirect()->route('dashboard')->with('status', 'Two factor authentication enabled');
        }

        return redirect()->back()->withErrors(['one_time_password' => 'The provided OTP is invalid']);
    }

    /**
     * Disable two factor authentication.
     */
    public function disable(Request $request)
    {

        $user = $request->user();
        $user->two_factor_secret         = null;
        $user->two_factor_recovery_codes = null;
        $user->save();

        //dump('user',$user->toArray());

        //return redirect()->back()->with('status', 'Two factor authentication disabled');
        // redirect to the dashboard
        return redirect()->route('dashboard')->with('status', 'Two factor authentication disabled');
    }
}