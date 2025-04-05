
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Set Up Two Factor Authentication</title>
</head>
<body>
    <h1>Two Factor Authentication Setup</h1>
    <p>Scan this QR code with your authenticator app:</p>
    {!! $QR_Image !!}

    <p>If you cannot scan the QR code, use this secret key: <strong>{{ $secret }}</strong></p>

    <form method="POST" action="{{ route('2fa.enable') }}">
        @csrf
        <label for="one_time_password">Enter the code from your app:</label>
        <input type="text" name="one_time_password" id="one_time_password" required>
        <button type="submit">Enable 2FA</button>
    </form>

    <hr>

    <form method="POST" action="{{ route('2fa.disable') }}">
        @csrf
        <button type="submit">Disable 2FA</button>
    </form>

    @if(session('status'))
        <p style="color: green;">{{ session('status') }}</p>
    @endif

    @if($errors->any())
        <p style="color: red;">{{ $errors->first('one_time_password') }}</p>
    @endif
</body>
</html>