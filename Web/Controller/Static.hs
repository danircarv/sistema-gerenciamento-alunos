module Web.Controller.Static where
import Web.Controller.Prelude
import Web.View.Static.Welcome

instance Controller StaticController where
    beforeAction = ensureIsUser

    action WelcomeAction = do
        matriculas <- carregarMatriculas
        totalAlunos <- query @Student |> fetchCount
        cursos <- map cursoDeCourse <$> (query @Course |> orderBy #name |> fetch)
        render WelcomeView { .. }
