import pandas as pd

with open ("jacana_from_gallus_gallus.gtf") as f:
    gtf = list(f)

gtf = [x for x in gtf if not x.startswith('#')]
print("The length of the gtf file is:")
print(len(gtf))
print("\n")

gtf = [x for x in gtf if 'gene_id "' in x and 'Name "' in x]

print("The length of unique gene IDs is:")
print(len(gtf)) 

new_gtf = list(map(lambda x: (x.split('gene_id "')[1].split('"')[0], x.split('Name "')[1].split('"')[0]), gtf))

print(new_gtf[0:5])

new_gtf = list(set(new_gtf))

print("The number of unique gene names:")
print(len(new_gtf))

new_gtf = dict(new_gtf)

df = pd.read_csv("jacana_gene_counts.csv")
print(df[0:5])

df["Gene Name"] = df["Unnamed: 0"].map(new_gtf)

df.to_csv("counts_with_genes.csv", index=True)
