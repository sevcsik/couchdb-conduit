{-# LANGUAGE OverloadedStrings #-}

-- | Internal
module Database.CouchDB.Conduit.Internal.Doc (
    couchRev,
    couchDelete,
    couchGetRaw
) where

import              Data.Maybe (fromJust)

import qualified    Data.ByteString as B
import qualified    Data.Aeson as A

import              Data.Conduit (runResourceT, ($$))
import qualified    Data.Conduit.Attoparsec as CA
import qualified    Network.HTTP.Conduit as H
import              Network.HTTP.Types as HT

import              Database.CouchDB.Conduit

------------------------------------------------------------------------------
-- Type-independent methods
------------------------------------------------------------------------------

-- | Get Revision of a document. 
couchRev :: MonadCouch m => 
       Path 
    -> m Revision
couchRev p = runResourceT $ do
    (H.Response _ hs _) <- couch HT.methodHead p [] [] 
            (H.RequestBodyBS B.empty)
            protect'
    return $ extractRev hs        
  where
    extractRev = B.tail . B.init . fromJust . lookup "Etag"


-- | Delete the given revision of the object.    
couchDelete :: MonadCouch m => 
       Path 
    -> Revision
    -> m ()
couchDelete p r = runResourceT $ couch HT.methodDelete p 
               [] [("rev", Just r)]
               (H.RequestBodyBS B.empty)
               protect' >> return ()
               
------------------------------------------------------------------------------
-- low-level 
------------------------------------------------------------------------------

-- | Load raw 'A.Value' from single object from couch DB.
couchGetRaw :: MonadCouch m => 
       Path         -- ^ Document path
    -> HT.Query     -- ^ Query
    -> m A.Value
couchGetRaw p q = runResourceT $ do
    H.Response _ _ bsrc <- couch HT.methodGet p [] q 
            (H.RequestBodyBS B.empty) protect'
    bsrc $$ CA.sinkParser A.json
    

