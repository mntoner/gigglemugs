<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Two-Factor Authentication Challenge</title>
</head>
<body>
    <h1>Two-Factor Authentication</h1>
    <p>Please enter the code from your authenticator app to continue.</p>

    <form method="POST" action="{{ route('2fa.challenge.store') }}">
        @csrf
        <label for="one_time_password">One-Time Password:</label>
        <input type="text" name="one_time_password" id="one_time_password" required autofocus>
        <button type="submit">Verify</button>
    </form>

    @if ($errors->has('one_time_password'))
        <div style="color: red;">
            {{ $errors->first('one_time_password') }}
        </div>
    @endif
</body>
</html> 