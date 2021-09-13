module Psvm.Types where

import Prelude

import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (Aff, attempt, launchAff_)
import Effect.Class as EFfect
import Effect.Class.Console as Console
import Effect.Exception (Error, message)
import Node.Process as Process
import Run (AFF, EFFECT, Run, liftAff, runBaseAff')
import Run.Except (EXCEPT, Except(..), liftExcept, runExcept)
import Run.Reader (READER, runReader)
import Type.Row (type (+))

-- | Failure types consumed by the app.
data Failure = Exit Int String

derive instance Eq Failure

-- | Exit with a code and message.
exit :: forall a. Int -> String -> Psvm a
exit c m = liftExcept $ Except (Exit c m)

-- | Exit with a code and an `Error`.
exitError :: forall a. Int -> Error -> Psvm a
exitError c = exit c <<< message

-- | Run an optionally-failing action.
runFailure :: forall r a. Run (EXCEPT Failure + r) a -> Run r (Either Failure a)
runFailure = runExcept

-- | Environment type consumed by the app.
type Env = {}

-- | Extensible row of effects for `run`.
type PSVM =
  ( READER Env
      + EXCEPT Failure
      + AFF
      + EFFECT
      + ()
  )

-- | Base monad type consumed by the app.
type Psvm a = Run PSVM a

-- | Run the `PSVM` effect stack.
runPsvm :: forall a. Env -> Psvm a -> Effect Unit
runPsvm e = launchAff_ <<< runFailureBaseAff <<< runFailure <<< runReader e
  where
  runFailureBaseAff m = do
    u <- runBaseAff' m
    case u of
      Left f -> case f of
        Exit code message -> EFfect.liftEffect do
          Console.error message
          Process.exit code
      Right r -> pure r

-- | Lift and catch `Aff` action errors in `Psvm`.
liftCatchAff :: forall r. Aff r -> (Error -> Psvm r) -> Psvm r
liftCatchAff action onFail = liftAff (attempt action) >>= either onFail pure
