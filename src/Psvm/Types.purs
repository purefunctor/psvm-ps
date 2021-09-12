module Psvm.Types where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Console as Console
import Node.Process as Process
import Run (EFFECT, Run, liftEffect, runBaseEffect)
import Run.Except (EXCEPT, Except(..), liftExcept, runExcept)
import Run.Reader (READER, runReader)
import Type.Row (type (+))

-- | Failure types consumed by the app.
data Failure = Exit Int String

derive instance Eq Failure

-- | Exit with a code and message.
exit :: forall a. Int -> String -> Psvm a
exit c m = liftExcept $ Except (Exit c m)

-- | Raise a `Failure` into `Effect`.
runFailure :: forall r a. Run (EXCEPT Failure + EFFECT + r) a -> Run (EFFECT + r) a
runFailure m = do
  u <- runExcept m
  case u of
    Left f -> case f of
      Exit code message -> liftEffect do
        Console.error message
        Process.exit code
    Right r -> pure r

-- | Environment type consumed by the app.
type Env = {}

-- | Extensible row of effects for `run`.
type PSVM =
  ( READER Env
      + EXCEPT Failure
      + EFFECT
      + ()
  )

-- | Base monad type consumed by the app.
type Psvm a = Run PSVM a

-- | Run the `PSVM` effect stack.
runPsvm :: forall a. Env -> Psvm a -> Effect a
runPsvm e = runBaseEffect <<< runFailure <<< runReader e
