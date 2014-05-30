\begin{code}
{-# LANGUAGE TypeFamilies #-}

{-# LANGUAGE MultiParamTypeClasses , FlexibleContexts,UndecidableInstances #-}

module  Numerical.Internal.Data.Vector.Pair(
    VPair(..)
    ,vPair
    ,vUnPair
    ,MVPair(..)
    ,mvUnPair
    ,mvPair
      ) where

import qualified Data.Vector.Generic as V
import qualified Data.Vector.Generic.Mutable as MV

import Control.Monad.Primitive (PrimMonad)

type instance V.Mutable (VPair v) = MVPair (V.Mutable v)


{-
currently primmonad doesn't get its free applicative/functor powers :*(

-}

(<$$$>) :: PrimMonad m => (a->b) -> m a -> m b
(<$$$>) f mv = do v <- mv ; return (f v )
{-# INLINE (<$$$>) #-}

(<***>) :: PrimMonad m => m (a->b) -> m a -> m b
(<***>) mf mv =  do f <- mf ; v <- mv ; return (f v)
{-# INLINE (<***>) #-}

-- need to write  VPair and MVPair as data families to force only taking tuples
-- if you ever write new instances, its your own fault if anything weird happens :)
-- maybe a

data family VPair (vect :: * -> * ) val
data instance VPair v (a,b)= TheVPair !(v a) !(v b)

vPair :: (v a,v b)->VPair v (a,b)
vPair  = \ (va,vb) ->  TheVPair va vb
{-# INLINE vPair #-}

vUnPair  :: VPair v (a,b) -> (v a, v b)
vUnPair = \ (TheVPair va vb)-> (va,vb)
{-# INLINE vUnPair #-}


data family MVPair (vect :: * -> * -> *) st val
data instance MVPair mv st (a,b) = TheMVPair !(mv st a) !(mv st b)


mvPair :: (mv st a,mv st b)->MVPair mv st (a,b)
mvPair  = \ (mva, mvb) ->  TheMVPair mva mvb
{-# INLINE mvPair #-}

mvUnPair  :: MVPair mv st  (a,b) -> (mv st a,mv st b)
mvUnPair = \ (TheMVPair mva mvb)-> (mva,mvb)
{-# INLINE mvUnPair #-}

instance  (MV.MVector (MVPair (V.Mutable v))(a,b) ,V.Vector v a,V.Vector v b)
  => V.Vector (VPair v) (a,b)  where
    basicUnsafeFreeze = \(TheMVPair mva mvb) ->
      TheVPair <$$$> V.basicUnsafeFreeze mva <***> V.basicUnsafeFreeze mvb
    basicUnsafeThaw = \(TheVPair va vb) ->
      TheMVPair <$$$> V.basicUnsafeThaw va <***> V.basicUnsafeThaw vb
    basicLength = \(TheVPair va _) -> V.basicLength va
    basicUnsafeSlice = \start len (TheVPair va vb) ->
      TheVPair (V.basicUnsafeSlice start len va) (V.basicUnsafeSlice start len vb)
    basicUnsafeIndexM = \(TheVPair va vb) ix ->
      do
          a <- V.basicUnsafeIndexM va ix
          b <- V.basicUnsafeIndexM vb ix
          return (a,b)

instance (MV.MVector mv a,MV.MVector mv b) => MV.MVector (MVPair mv ) (a,b) where
  basicLength = \ (TheMVPair mva _) -> MV.basicLength mva
  {-# INLINE basicLength #-}

  basicUnsafeSlice = \ start len (TheMVPair mva mvb )->
    TheMVPair (MV.basicUnsafeSlice start len mva) (MV.basicUnsafeSlice start len mvb)
  {-# INLINE basicUnsafeSlice#-}

  basicOverlaps = \ (TheMVPair mva mvb) (TheMVPair mva2 mvb2)-> (MV.basicOverlaps mva mva2) || (MV.basicOverlaps mvb mvb2)
  {-# INLINE basicOverlaps #-}

  basicUnsafeNew =
      \ size ->
          TheMVPair <$$$> MV.basicUnsafeNew size <***> MV.basicUnsafeNew size
  {-# INLINE basicUnsafeNew #-}

  basicUnsafeReplicate =
      \ size (a,b) ->
         TheMVPair <$$$>
            MV.basicUnsafeReplicate size a <***>
            MV.basicUnsafeReplicate size b

  {-# INLINE basicUnsafeReplicate #-}

  basicUnsafeRead = \(TheMVPair mva mvb) ix ->
    (,) <$$$>  MV.basicUnsafeRead mva ix <***> MV.basicUnsafeRead mvb ix

  {-#INLINE basicUnsafeRead#-}

  basicUnsafeWrite = \ (TheMVPair mva mvb) ix (a,b) ->
    do
      MV.basicUnsafeWrite mva ix a
      MV.basicUnsafeWrite mvb ix b
      return ()
  {-#INLINE basicUnsafeWrite#-}


  basicUnsafeGrow = \ (TheMVPair mva mvb) growth ->
      TheMVPair <$$$> MV.basicUnsafeGrow mva growth <***>
          MV.basicUnsafeGrow mvb growth





\end{code}
