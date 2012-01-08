{-# LANGUAGE OverloadedStrings #-}

module Database.CouchDB.Conduit.Internal.Parser where

import              Data.Conduit
import qualified    Data.ByteString.UTF8 as BU8
import qualified    Data.Text as T
import qualified    Data.Text.Encoding as TE
import qualified    Data.HashMap.Lazy as M
import qualified    Data.Aeson as A

import              Database.CouchDB.Conduit

--valToRev :: A.Value -> Either CouchError Revision
--valToRev (A.Object o) = case M.lookup "rev" o of
--    (Just (A.String r)) -> Right $ TE.encodeUtf8 r
--    _  -> Left $ CouchError Nothing "unable to find revision"  
--valToRev _ = Left $ CouchError Nothing "Couch DB did not return an object"

extractRev :: ResourceIO m => A.Value -> m Revision
extractRev o = do
    A.String r <- extractField "rev" o
    return $ TE.encodeUtf8 r

-- | Extract single field
extractField :: ResourceIO m =>
           T.Text -> A.Value -> m A.Value
extractField s (A.Object o) = case M.lookup s o of
    (Just r) -> return r
    _  -> resourceThrow $ CouchError Nothing $
            "unable to find field" ++ (BU8.toString . TE.encodeUtf8 $ s)  
extractField _ _ = resourceThrow $ CouchError Nothing 
        "Couch DB did not return an object"

-- | Convert to type with given convertor
jsonToTypeWith :: ResourceIO m =>
                (A.Value -> A.Result a) 
             -> A.Value 
             -> m a
jsonToTypeWith f j = case f j of
        A.Error e -> resourceThrow $ CouchError Nothing 
                        ("Error parsing json: " ++ e)
        A.Success o -> return o
