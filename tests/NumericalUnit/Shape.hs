-- {-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE DataKinds, GADTs, TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables  #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FunctionalDependencies #-}

module NumericalUnit.Shape(unitTestShape) where

import Test.HUnit
import Numerical.Array.Shape as S
import qualified Data.Vector.Storable as SV
import qualified Data.Vector.Unboxed as UV
import Prelude as P
import Test.Tasty
import Test.Tasty.HUnit hiding ((@?=))

unitTestShape = testGroup "Shape Unit tests"
        [ testCase "foldl on shape" $  S.foldl (+) 0 (1:* 2:* 3 :* Nil )  @?=   P.foldl   (+) 0  [1,2,3]
        , testCase "foldr on shape" $  S.foldr (+) 0 (1:* 2:* 3 :* Nil )  @?=   P.foldr  (+) 0  [1,2,3]
        , testCase "foldl1 on shape" $  S.foldl1 (+) (1:* 2:* 3 :* Nil )  @?=   P.foldl1   (+)  [1,2,3]
        , testCase "foldr1 on shape" $  S.foldr1 (+) (1:* 2:* 3 :* Nil )  @?=   P.foldr1  (+)  [1,2,3]



        , testCase "shapeToList on shape" $  S.shapeToList (1:* 2 :* 3 :* Nil) @?= [1,2,3]


        , testCase "Show on Nil shape" $ show Nil @?= "Nil"
        , testCase "Show on 1:* Nil"  $ show (1:* Nil) @?= "1 :* Nil"

        , testCase "storable on size 0 shape" $
            do a <- return (svFromList [Nil,Nil :: Shape Z Int]) ; SV.toList a @?= [Nil,Nil]
        , testCase "storable on size 1 shape" $
            do a <- return (svFromList [1:*Nil,2:*Nil :: Shape (S Z) Int]) ; SV.toList a @?= [1:*Nil,2:*Nil]
        , testCase "storable on size 2 shape" $
            do  a <- return (svFromList [3:* 4:* Nil,1:*2:*Nil :: Shape (S (S Z)) Int]) ;
                SV.toList a @?= [3:* 4:* Nil,1:*2:*Nil]

        , testCase "unboxed on size 0 shape" $
            do a <- return (uvFromList [Nil,Nil :: Shape Z Int]) ; UV.toList a @?= [Nil,Nil]
        , testCase "unboxed on size 1 shape" $
            do a <- return (uvFromList [1:*Nil,2:*Nil :: Shape (S Z) Int]) ; UV.toList a @?= [1:*Nil,2:*Nil]
        , testCase "unboxed on size 2 shape" $
            do  a <- return (uvFromList [3:* 4:* Nil,1:*2:*Nil :: Shape (S (S Z)) Int]) ;
                UV.toList a @?= [3:* 4:* Nil,1:*2:*Nil]
        ]
    where
        {- The NOINLINE is need to properly check storable /unboxed instances, otherwise fusion removes the allocation! -}
        svFromList  :: SV.Storable a => [a] -> SV.Vector a
        svFromList = SV.fromList
        {-# NOINLINE svFromList #-}

        uvFromList :: UV.Unbox a => [a] -> UV.Vector a
        uvFromList = UV.fromList
        {-# NOINLINE uvFromList#-}
