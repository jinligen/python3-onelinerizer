{-# LANGUAGE BlockArguments #-}

module Main where

import System.IO (IOMode(ReadMode), hGetContents, hSetEncoding, utf8, withFile)

import qualified Language.Python.Common as Python
import qualified Language.Python.Version3 as Python3

main :: IO ()
main = do
  let srcFileName = "test.py"
  withFile srcFileName ReadMode \h -> do
    hSetEncoding h utf8
    contents <- hGetContents h
    case Python3.parseModule contents srcFileName of
      Left e -> pure ()
      Right (a, _) -> print a

onelinerize :: Python.ModuleSpan -> Bool
onelinerize = const True
