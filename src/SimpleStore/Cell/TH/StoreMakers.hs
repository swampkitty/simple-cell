{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

{- | StateMakers are TH functions that assemble the insert state, delete state and update state pieces of a live DB
     entity.
|-}
module SimpleStore.Cell.TH.StoreMakers (
                                      allStoreMakers
                            ) where



import           Language.Haskell.TH

import           SimpleStore.Cell.DIG



type CellKeyName     = Name
type InitializerName = Name
type StoreName       = Name








allStoreMakers :: [CellKeyName -> InitializerName -> StoreName -> Q Dec]
allStoreMakers = [ makeInitializeXSimpleCell
                 , makeInsertXSimpleCell
                 , makeDeleteXSimpleCell
                 , makeFoldlWithKeyXSimpleCell
                 , makeTraverseWithKeyXSimpleCell
                 , makeCreateCheckpointAndCloseXSimpleCell
                 , makeUpdateXSimpleCell
                 , makeGetXSimpleCell
                 ]



                 
-- -- The X represents the position of the incoming type in the filename
makeInitializeXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeInitializeXSimpleCell ckN initN stN = funD (buildInitName stN)
                                             [clause [] (normalB initializeSimpleCellTH ) []  ]
  where
    initializeSimpleCellTH = appE (appE (varE 'initializeSimpleCell ) (varE ckN)) (varE initN)

buildInitName :: StoreName -> Name
buildInitName stN = mkName.concat $ [ "initialize"
                                   , nameBase stN
                                   , "SC"]

makeInsertXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeInsertXSimpleCell ckN _initN stN = funD (buildInsertName stN)
                                          [clause [] (normalB insertSimpleCellTH) []  ]
  where
    insertSimpleCellTH =appE (varE 'insertStore ) (varE ckN)

buildInsertName :: StoreName -> Name
buildInsertName stN = (mkName.concat)  [  "insert"
                                       , nameBase stN
                                       , "SC"]


makeUpdateXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeUpdateXSimpleCell ckN _initN stN = funD (buildUpdateName stN)
                                           [clause [] (normalB updateSimpleCellTH) []  ]
  where
    updateSimpleCellTH = appE (varE 'updateStore ) (varE ckN)

buildUpdateName :: StoreName -> Name
buildUpdateName stN = (mkName.concat)  [ "update"
                                      , nameBase stN
                                      , "SC"]


makeDeleteXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeDeleteXSimpleCell ckN _ stN = funD (buildDeleteName stN)
                                     [clause [] (normalB deleteSimpleCellTH) []  ]
  where
    deleteSimpleCellTH =  appE (varE 'deleteStore )
                               (varE ckN)

buildDeleteName :: StoreName -> Name
buildDeleteName stN = mkName.concat $ [ "delete"
                                     , nameBase stN
                                     , "SC"]



makeGetXSimpleCell :: CellKeyName -> InitializerName -> StoreName -> Q Dec
makeGetXSimpleCell ckN _ stN = funD (buildGetName stN)
                                  [clause [] (normalB getSimpleCellTH) [] ]
 where
   getSimpleCellTH = appE (varE 'getStore )
                          (varE ckN)


buildGetName :: StoreName -> Name
buildGetName stN = mkName.concat $ ["get", (nameBase stN), "SC"]



makeFoldlWithKeyXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeFoldlWithKeyXSimpleCell ckN _ stN = funD (buildFoldlWithKeyName stN)
                                           [clause [] (normalB foldlWithKeySimpleCellTH) []  ]
  where
    foldlWithKeySimpleCellTH = appE (varE 'storeFoldrWithKey )
                                    (varE ckN)



buildFoldlWithKeyName :: StoreName -> Name
buildFoldlWithKeyName stN = (mkName.concat) [ "foldlWithKey"
                                          , nameBase stN
                                          , "SC"]



makeTraverseWithKeyXSimpleCell ::  CellKeyName -> InitializerName -> StoreName -> Q Dec
makeTraverseWithKeyXSimpleCell ckN _ stN = funD (buildTraverseWithKeyName stN)
                                             [clause [] (normalB traverseWithKeySimpleCellTH) []  ]
  where
    traverseWithKeySimpleCellTH = appE (varE 'storeTraverseWithKey_ )
                                       (varE ckN)



buildTraverseWithKeyName :: StoreName -> Name
buildTraverseWithKeyName stN = (mkName.concat)  [ "traverseWithKey"
                                              , nameBase stN
                                              , "SC_"]





makeCreateCheckpointAndCloseXSimpleCell :: CellKeyName -> InitializerName -> StoreName -> Q Dec
makeCreateCheckpointAndCloseXSimpleCell _ckN _ stN = funD (buildCheckPointAndCloseName stN)
                                                      [clause [] (normalB createCheckpointAndCloseSimpleCellTH) []  ]
  where
    createCheckpointAndCloseSimpleCellTH = varE 'createCellCheckPointAndClose

buildCheckPointAndCloseName :: StoreName -> Name
buildCheckPointAndCloseName stN = (mkName.concat)  [  "createCheckpointAndClose"
                                                  , nameBase stN
                                                  , "SC"]



-- makeArchiveAndHandleXSimpleCell :: CellKeyName -> InitializerName -> StoreName -> Q Dec
-- makeArchiveAndHandleXSimpleCell ckN _ stN = do
--   f <- (funD (buildArchiveAndHandleName stN)) [(clause [] (normalB archiveAndHandleTH) [] ) ]
--   return f
--   where
--     archiveAndHandleTH = (appE (varE 'archiveAndHandle ) (varE ckN))


-- buildArchiveAndHandleName :: StoreName -> Name
-- buildArchiveAndHandleName stN = mkName.concat $ ["archiveAndHandle", (nameBase stN), "SC"]
