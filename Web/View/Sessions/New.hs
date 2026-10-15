module Web.View.Sessions.New where

import Web.View.Prelude
import IHP.AuthSupport.View.Sessions.New

instance View (NewView User) where
    html NewView { .. } = [hsx|
        <div class="mx-auto mt-5" style="max-width: 400px">
            <h1 class="h4 mb-1">Entrar</h1>
            <p class="text-muted mb-4">Use sua conta de administrador ou de professor.</p>
            {renderForm user}
        </div>
    |]

renderForm :: User -> Html
renderForm user = [hsx|
    <form method="POST" action={CreateSessionAction}>
        <div class="mb-3">
            <label class="form-label" for="email">E-mail</label>
            <input id="email" name="email" value={user.email} type="email" class="form-control" required="required" autofocus="autofocus"/>
        </div>
        <div class="mb-3">
            <label class="form-label" for="password">Senha</label>
            <input id="password" name="password" type="password" class="form-control" required="required"/>
        </div>
        <button type="submit" class="btn btn-primary w-100">Entrar</button>
    </form>
|]
