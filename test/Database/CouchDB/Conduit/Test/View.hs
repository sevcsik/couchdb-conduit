{-# LANGUAGE OverloadedStrings #-}

module Database.CouchDB.Conduit.Test.View where

import Test.Framework (testGroup, mutuallyExclusive, Test)
import Test.Framework.Providers.HUnit (testCase)
import Test.HUnit (Assertion, (@=?))

import Control.Monad.Trans.Class (lift)
import Control.Monad.IO.Class (liftIO)

import Data.Conduit
import qualified Data.Conduit.List as CL
import qualified Data.HashMap.Lazy as M

import Database.CouchDB.Conduit
import Database.CouchDB.Conduit.View

tests :: Test
tests = mutuallyExclusive $ testGroup "View" [
    testCase "Basic" case_basicView
--    testCase "Just put-delete" case_massFlow
    ]

case_basicView :: Assertion
case_basicView = runCouch "localhost" 5984 "cdbc_test" $ do
    res <- couchView "test" "group1" [] $ 
        CL.mapM (liftIO . print) =$ CL.consume
    liftIO $ print res