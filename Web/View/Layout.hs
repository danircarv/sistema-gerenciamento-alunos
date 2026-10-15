module Web.View.Layout (defaultLayout, Html) where

import IHP.ViewPrelude
import IHP.Environment
import Generated.Types
import Web.Types
import Web.Routes
import Application.Helper.View

defaultLayout :: Html -> Html
defaultLayout inner = [hsx|
<!DOCTYPE html>
<html lang="en">
    <head>
        {metaTags}

        {stylesheets}
        {scripts}

        <title>{pageTitleOrDefault "App"}</title>
    </head>
    <body>
        <nav class="navbar navbar-expand bg-body-tertiary border-bottom">
            <div class="container">
                <a class="navbar-brand" href={WelcomeAction}>Gestão de Alunos</a>
                {renderMenu currentUserOrNothing}
            </div>
        </nav>
        <div class="container mt-4">
            {renderFlashMessages}
            {inner}
        </div>
    </body>
</html>
|]

renderMenu :: Maybe User -> Html
renderMenu Nothing = mempty
renderMenu (Just user) = [hsx|
    <div class="navbar-nav me-auto">
        <a class="nav-link" href={WelcomeAction}>Painel</a>
        <a class="nav-link" href={StudentsAction}>Students</a>
        <a class="nav-link" href={CoursesAction}>Courses</a>
        <a class="nav-link" href={EnrollmentsAction}>Enrollments</a>
        <a class="nav-link" href={GradesAction}>Grades</a>
    </div>
    <div class="navbar-nav align-items-center">
        <span class="navbar-text me-3">{user.name} · <span class="badge bg-secondary">{descreverPapel user.role_}</span></span>
        <a class="nav-link js-delete js-delete-no-confirm" href={DeleteSessionAction}>Sair</a>
    </div>
|]

stylesheets :: Html
stylesheets = [hsx|
        <link rel="stylesheet" href={assetPath "/vendor/bootstrap-5.3.8/bootstrap.min.css"}/>
        <link rel="stylesheet" href={assetPath "/vendor/flatpickr.min.css"}/>
        <link rel="stylesheet" href={assetPath "/app.css"}/>
    |]

scripts :: Html
scripts = [hsx|
        {when isDevelopment devScripts}
        <script src={assetPath "/vendor/jquery-4.0.0.slim.min.js"}></script>
        <script src={assetPath "/vendor/timeago.js"}></script>
        <script src={assetPath "/vendor/popper-2.11.6.min.js"}></script>
        <script src={assetPath "/vendor/bootstrap-5.3.8/bootstrap.min.js"}></script>
        <script src={assetPath "/vendor/flatpickr.js"}></script>
        <script src={assetPath "/vendor/morphdom-umd.min.js"}></script>
        <script src={assetPath "/vendor/turbolinks.js"}></script>
        <script src={assetPath "/vendor/turbolinksInstantClick.js"}></script>
        <script src={assetPath "/vendor/turbolinksMorphdom.js"}></script>
        <script src={assetPath "/helpers.js"}></script>
        <script src={assetPath "/ihp-auto-refresh.js"}></script>
        <script src={assetPath "/app.js"}></script>
    |]

devScripts :: Html
devScripts = [hsx|
        <script id="livereload-script" src={assetPath "/livereload.js"} data-ws={liveReloadWebsocketUrl}></script>
    |]

metaTags :: Html
metaTags = [hsx|
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"/>
    <meta property="og:title" content="App"/>
    <meta property="og:type" content="website"/>
    <meta property="og:url" content="TODO"/>
    <meta property="og:description" content="TODO"/>
    {autoRefreshMeta}
|]
