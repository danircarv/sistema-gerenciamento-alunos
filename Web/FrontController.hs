module Web.FrontController where

import IHP.RouterPrelude
import Web.Controller.Prelude
import Web.View.Layout (defaultLayout)

-- Controller Imports
import Web.Controller.Grades
import Web.Controller.Enrollments
import Web.Controller.Courses
import Web.Controller.Students
import Web.Controller.Static
import Web.Controller.Sessions

instance FrontController WebApplication where
    controllers = 
        [ startPage WelcomeAction
        , parseRoute @SessionsController
        -- Generator Marker
        , parseRoute @GradesController
        , parseRoute @EnrollmentsController
        , parseRoute @CoursesController
        , parseRoute @StudentsController
        ]

instance InitControllerContext WebApplication where
    initContext = do
        setLayout defaultLayout
