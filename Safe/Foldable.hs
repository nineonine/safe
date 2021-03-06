{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE CPP              #-}
{-# LANGUAGE ConstraintKinds  #-}
{- |
'Foldable' functions, with wrappers like the "Safe" module.
-}
module Safe.Foldable(
    -- * New functions
    findJust,
    -- * Safe wrappers
    foldl1May, foldl1Def, foldl1Note,
    foldr1May, foldr1Def, foldr1Note,
    findJustDef, findJustNote,
    minimumMay, minimumDef, minimumNote,
    maximumMay, maximumDef, maximumNote,
    minimumByMay, minimumByDef, minimumByNote,
    maximumByMay, maximumByDef, maximumByNote,
    -- * Deprecated
    foldl1Safe, foldr1Safe, findJustSafe
    ) where

import Safe.Util
import Data.Foldable as F
import Data.Maybe
import Data.Monoid
import Prelude
import Safe.Partial


---------------------------------------------------------------------
-- UTILITIES

fromNote :: Partial => String -> String -> Maybe a -> a
fromNote = fromNoteModule "Safe.Foldable"

isNull :: Foldable t => t a -> Bool
#if __GLASGOW_HASKELL__ < 710
isNull = null . toList
#else
isNull = F.null
#endif

---------------------------------------------------------------------
-- WRAPPERS

foldl1May, foldr1May :: Foldable t => (a -> a -> a) -> t a -> Maybe a
foldl1May = liftMay isNull . F.foldl1
foldr1May = liftMay isNull . F.foldr1

foldl1Note, foldr1Note :: (Partial, Foldable t) => String -> (a -> a -> a) -> t a -> a
foldl1Note note f x = withFrozenCallStack $ fromNote note "foldl1Note on empty" $ foldl1May f x
foldr1Note note f x = withFrozenCallStack $ fromNote note "foldr1Note on empty" $ foldr1May f x

foldl1Def, foldr1Def :: Foldable t => a -> (a -> a -> a) -> t a -> a
foldl1Def def = fromMaybe def .^ foldl1May
foldr1Def def = fromMaybe def .^ foldr1May

minimumMay, maximumMay :: (Foldable t, Ord a) => t a -> Maybe a
minimumMay = liftMay isNull F.minimum
maximumMay = liftMay isNull F.maximum

minimumDef, maximumDef :: (Foldable t, Ord a) => a -> t a -> a
minimumDef def = fromMaybe def . minimumMay
maximumDef def = fromMaybe def . maximumMay

minimumNote, maximumNote :: (Partial, Foldable t, Ord a) => String -> t a -> a
minimumNote note x = withFrozenCallStack $ fromNote note "minimumNote on empty" $ minimumMay x
maximumNote note x = withFrozenCallStack $ fromNote note "maximumNote on empty" $ maximumMay x

minimumByMay, maximumByMay :: Foldable t => (a -> a -> Ordering) -> t a -> Maybe a
minimumByMay = liftMay isNull . F.minimumBy
maximumByMay = liftMay isNull . F.maximumBy

minimumByDef, maximumByDef :: Foldable t => a -> (a -> a -> Ordering) -> t a -> a
minimumByDef def = fromMaybe def .^ minimumByMay
maximumByDef def = fromMaybe def .^ maximumByMay

minimumByNote, maximumByNote :: (Partial, Foldable t) => String -> (a -> a -> Ordering) -> t a -> a
minimumByNote note f x = withFrozenCallStack $ fromNote note "minimumByNote on empty" $ minimumByMay f x
maximumByNote note f x = withFrozenCallStack $ fromNote note "maximumByNote on empty" $ maximumByMay f x

-- |
-- > findJust op = fromJust . find op
findJust :: (Partial, Foldable t) => (a -> Bool) -> t a -> a
findJust f x = withFrozenCallStack $ fromNote "" "findJust, no matching value" $ F.find f x

findJustDef :: Foldable t => a -> (a -> Bool) -> t a -> a
findJustDef def = fromMaybe def .^ F.find

findJustNote :: (Partial, Foldable t) => String -> (a -> Bool) -> t a -> a
findJustNote note f x = withFrozenCallStack $ fromNote note "findJustNote, no matching value" $ F.find f x


---------------------------------------------------------------------
-- DEPRECATED

{-# DEPRECATED foldl1Safe "Use @foldl f mempty@ instead." #-}
foldl1Safe :: (Monoid m, Foldable t) => (m -> m -> m) -> t m -> m
foldl1Safe fun = F.foldl fun mempty

{-# DEPRECATED foldr1Safe "Use @foldr f mempty@ instead." #-}
foldr1Safe :: (Monoid m, Foldable t) => (m -> m -> m) -> t m -> m
foldr1Safe fun = F.foldr fun mempty


{-# DEPRECATED findJustSafe "Use @findJustDef mempty@ instead." #-}
findJustSafe :: (Monoid m, Foldable t) => (m -> Bool) -> t m -> m
findJustSafe = findJustDef mempty
