{-# LANGUAGE BlockArguments #-}

module Main where

import Data.List (intercalate)
import Data.Maybe (fromMaybe)
import System.IO (IOMode(ReadMode), hGetContents, hSetEncoding, utf8, withFile)

import qualified Control.Monad.Trans.State as TS

import qualified Language.Python.Common as Python
import qualified Language.Python.Version3 as Python3

main :: IO ()
main = do
  let srcFileName = "test.py"
  withFile srcFileName ReadMode \h -> do
    hSetEncoding h utf8
    contents <- hGetContents h
    case Python3.parseModule contents srcFileName of
      Left e -> print e
      Right (Python.Module xs, _) -> do
        print xs
        putStrLn $ Python.prettyText $ TS.evalState (onelinerize xs) 0

nil :: Python.SrcSpan
nil = Python.SpanEmpty

onelinerize :: [Python.StatementSpan] -> TS.State Word Python.ExprSpan
onelinerize (x : []) =
  case x of
    Python.Return returnExpr _ -> do
      pure $ fromMaybe (Python.None nil) returnExpr
    Python.StmtExpr stmtExpr _ -> do
      pure stmtExpr
    otherwise ->
      pure $ Python.None nil
onelinerize (x : xs) =
  case x of
    Python.Import importItems _ -> do
      let lambdaParams = [Python.Param (Python.Ident (fromMaybe (intercalate "." (Python.ident_string <$> Python.import_item_name importItem)) (Python.ident_string <$> Python.import_as_name importItem)) nil) Nothing Nothing nil | importItem <- importItems]
      let lambdaArgs = [Python.ArgExpr (Python.Call (Python.Var (Python.Ident "__import__" nil) nil) [Python.ArgExpr (Python.Strings [show (intercalate "." (Python.ident_string <$> Python.import_item_name importItem))] nil) nil] nil) nil | importItem <- importItems]
      restExpr <- onelinerize xs
      pure $ Python.Call (Python.Paren (Python.Lambda lambdaParams (Python.Paren restExpr nil) nil) nil) lambdaArgs nil
    Python.FromImport from_module import_items stmt_annot ->
      undefined
    Python.While while_cond while_body while_else stmt_annot ->
      undefined
    Python.For for_targets for_generator for_body for_else stmt_annot ->
      undefined
    Python.AsyncFor for_stmt stmt_annot ->
      undefined
    Python.Fun funName funArgs _ funBody _ -> do
      funBodyExpr <- onelinerize funBody
      let lambdaFun = Python.Assign [Python.Var funName nil] (Python.Lambda funArgs funBodyExpr nil) nil
      onelinerize (lambdaFun : xs)
    Python.AsyncFun fun_def stmt_annot ->
      undefined
    Python.Class class_name class_args class_body stmt_annot ->
      undefined
    Python.Conditional cond_guards cond_else stmt_annot ->
      undefined
    Python.Assign assignTo assignExpr _ -> do
      restExpr <- onelinerize xs
      pure $ Python.Call (Python.Var (Python.Ident "next" nil) nil) [Python.ArgExpr (Python.Tuple [Python.Generator (Python.Comprehension (Python.ComprehensionExpr restExpr) (Python.CompFor False assignTo (Python.Paren (Python.Tuple [Python.Paren assignExpr nil] nil) nil) Nothing nil) nil) nil] nil) nil] nil

    Python.StmtExpr stmtExpr _ -> do
      restExpr <- onelinerize xs
      pure $ Python.BinaryOp (Python.Or nil) (Python.Paren (Python.BinaryOp (Python.And nil) stmtExpr (Python.None nil) nil) nil) restExpr nil
