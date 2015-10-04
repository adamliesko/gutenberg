export GUTENBERG_DIR="/Users/Adam/gutenberg/"
./bin/mallet import-dir --input $GUTENBERG_DIR/lda/dataset_one_line --output $GUTENBERG_DIRlda/dataset_one_line/out --keep-sequence --remove-stopwords

.bin/mallet train-topics  --$GUTENBERG_DIR/lda/dataset_one_line/out  --num-topics 20 --optimize-interval 20 --output-state $GUTENBERG_DIR/topic-state.gz  --output-topic-keys $GUTENBERG_DIR/gutenberg_keys.txt --output-doc-topics $GUTENBERG_DIR/gutenberg_composition.txt
