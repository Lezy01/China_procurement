import sys, pandas as pd, numpy as np

# 读取目录 embedding
catalog = pd.read_pickle("catalog_with_embeddings.pkl")
catalog_emb = np.vstack(catalog["embedding"].apply(np.array).values)
catalog_emb = catalog_emb / np.linalg.norm(catalog_emb, axis=1, keepdims=True)

codes = catalog["编  码"].values
names = catalog["品目名称"].values
cats  = catalog["品目类别"].values

# 读取当前文件
fname = sys.argv[1]
proc = pd.read_pickle(fname)

proj_emb = np.vstack(proc["embedding_project"].apply(np.array).values)
item_emb = np.vstack(proc["embedding_item"].apply(np.array).values)

def normalize(m): return m / np.linalg.norm(m, axis=1, keepdims=True)

proj_emb = normalize(proj_emb)
item_emb = normalize(item_emb)

sim_proj = proj_emb @ catalog_emb.T
sim_item = item_emb @ catalog_emb.T
sim_comb = np.maximum(sim_proj, sim_item)

best_idx = np.argmax(sim_comb, axis=1)
best_score = np.max(sim_comb, axis=1)

proc["subcategory_code"] = codes[best_idx]
proc["subcategory_name"] = names[best_idx]
proc["category"] = cats[best_idx]
proc["pred_score"] = best_score

out = fname.replace(".pkl", "_classified.pkl")
proc.to_pickle(out)
proc.to_csv(out.replace(".pkl", ".csv"), index=False)
