{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | Collect all the basic TreeDiff stuff in one place.
--   Including orphan instances from external types.
--   So anyplace this module is imported to get access to the
--   ToExpr class, one also gets the orphan instances.
module Cardano.Ledger.TreeDiff (
  Expr (App, Rec, Lst),
  ToExpr (listToExpr, toExpr),
  defaultExprViaShow,
  trimExprViaShow,
)
where

import qualified Cardano.Crypto.DSIGN as DSIGN
import qualified Cardano.Crypto.Hash as Hash
import Cardano.Crypto.Hash.Class ()
import Cardano.Slotting.Block (BlockNo)
import Cardano.Slotting.Slot (EpochNo (..), EpochSize (..), SlotNo (..), WithOrigin (..))
import Data.Foldable (toList)
import Data.IP (IPv4, IPv6)
import Data.Maybe.Strict (StrictMaybe)
import Data.Sequence.Strict (StrictSeq)
import Data.TreeDiff.Class (ToExpr (listToExpr, toExpr), defaultExprViaShow)
import Data.TreeDiff.Expr (Expr (App, Lst, Rec))

-- =====================================================
-- Cardano functions that deal with TreeDiff and ToExpr

trimExprViaShow :: Show a => Int -> a -> Expr
trimExprViaShow _n x = defaultExprViaShow x -- App (take n (drop 1 (show x)) ++ "..") []

-- ===========================================================
-- Orphan instances from external imports

instance ToExpr IPv4

instance ToExpr IPv6

instance ToExpr SlotNo

instance ToExpr BlockNo

instance ToExpr EpochNo

instance ToExpr EpochSize

instance ToExpr x => ToExpr (WithOrigin x)

instance ToExpr (Hash.Hash c index) where
  toExpr = trimExprViaShow 10

instance DSIGN.DSIGNAlgorithm c => ToExpr (DSIGN.SignedDSIGN c index) where
  toExpr = trimExprViaShow 10

instance ToExpr a => ToExpr (StrictSeq a) where
  toExpr x = App "StrictSeqFromList" [listToExpr (toList x)]

instance ToExpr a => ToExpr (StrictMaybe a)
