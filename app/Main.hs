module Main where

import Test.Tasty.Bench ( bench, bgroup, defaultMain, nf, Benchmark, Benchmarkable )
import System.Random (randomRIO)

import qualified Sorts.New3WM
import qualified Sorts.New5WM
import qualified Sorts.Old

import Control.Monad (replicateM)
import Control.DeepSeq (NFData)

main :: IO ()
main = do
  tData <- mapM benchmark sizes
  defaultMain tData

sizes :: [Int]
sizes = [ 10, 1000, 1000000]

benchmark :: Int -> IO Benchmark
benchmark size = do
  dataN <- randoms size 10
  let name n = concat [n, " - ", show size]
      random   = mk (name "Random") dataN map
      sorted   = mk (name "Sorted") [1..size] id
      reversed = mk (name "Reverse-Sorted") (reverse [1..size]) id
  pure $ bgroup "sort" [random, sorted, reversed]

test :: (a -> [Int]) -> [a] -> Benchmarkable
test = nf . map

mk :: (Ord a, NFData b) => String -> c -> (([a] -> [a]) -> c -> b) -> Benchmark
mk name dataN f = bgroup name 
  [ bench "original" $ foo Sorts.Old.sort
  , bench "3 way merge" $ foo Sorts.New3WM.sort
  -- , bench "4 way merge" $ nf Sorts.New4WM.sort sortedN
  -- , bench "5 way merge no intermediate" $ test Sorts.New5WMBinPart.sort dataN
  , bench "5 way merge" $ foo Sorts.New5WM.sort
  ]
  where foo g = nf (f g) dataN

randoms :: Int -> Int -> IO [[Int]]
randoms n m = replicateM m $ replicateM n $ randomRIO (0, 10000)
