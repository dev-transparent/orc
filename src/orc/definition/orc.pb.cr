## Generated from orc.proto for orc.proto
require "protobuf"

module Orc
  module Proto
    enum EncryptionAlgorithm
      UNKNOWNENCRYPTION = 0
      AESCTR128 = 1
      AESCTR256 = 2
    end
    enum KeyProviderKind
      UNKNOWN = 0
      HADOOP = 1
      AWS = 2
      GCP = 3
      AZURE = 4
    end
    enum CalendarKind
      UNKNOWNCALENDAR = 0
      JULIANGREGORIAN = 1
      PROLEPTICGREGORIAN = 2
    end
    enum CompressionKind
      NONE = 0
      ZLIB = 1
      SNAPPY = 2
      LZO = 3
      LZ4 = 4
      ZSTD = 5
      BROTLI = 6
    end

    struct IntegerStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :sint64, 1
        optional :maximum, :sint64, 2
        optional :sum, :sint64, 3
      end
    end

    struct DoubleStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :double, 1
        optional :maximum, :double, 2
        optional :sum, :double, 3
      end
    end

    struct StringStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :string, 1
        optional :maximum, :string, 2
        optional :sum, :sint64, 3
        optional :lower_bound, :string, 4
        optional :upper_bound, :string, 5
      end
    end

    struct BucketStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :count, :uint64, 1, packed: true
      end
    end

    struct DecimalStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :string, 1
        optional :maximum, :string, 2
        optional :sum, :string, 3
      end
    end

    struct DateStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :sint32, 1
        optional :maximum, :sint32, 2
      end
    end

    struct TimestampStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :minimum, :sint64, 1
        optional :maximum, :sint64, 2
        optional :minimum_utc, :sint64, 3
        optional :maximum_utc, :sint64, 4
        optional :minimum_nanos, :int32, 5
        optional :maximum_nanos, :int32, 6
      end
    end

    struct BinaryStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :sum, :sint64, 1
      end
    end

    struct CollectionStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :min_children, :uint64, 1
        optional :max_children, :uint64, 2
        optional :total_children, :uint64, 3
      end
    end

    struct ColumnStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :number_of_values, :uint64, 1
        optional :int_statistics, IntegerStatistics, 2
        optional :double_statistics, DoubleStatistics, 3
        optional :string_statistics, StringStatistics, 4
        optional :bucket_statistics, BucketStatistics, 5
        optional :decimal_statistics, DecimalStatistics, 6
        optional :date_statistics, DateStatistics, 7
        optional :binary_statistics, BinaryStatistics, 8
        optional :timestamp_statistics, TimestampStatistics, 9
        optional :has_null, :bool, 10
        optional :bytes_on_disk, :uint64, 11
        optional :collection_statistics, CollectionStatistics, 12
      end
    end

    struct RowIndexEntry
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :positions, :uint64, 1, packed: true
        optional :statistics, ColumnStatistics, 2
      end
    end

    struct RowIndex
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :entry, RowIndexEntry, 1
      end
    end

    struct BloomFilter
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :num_hash_functions, :uint32, 1
        repeated :bitset, :fixed64, 2
        optional :utf8bitset, :bytes, 3
      end
    end

    struct BloomFilterIndex
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :bloom_filter, BloomFilter, 1
      end
    end

    struct Stream
      include ::Protobuf::Message
      enum Kind
        PRESENT = 0
        DATA = 1
        LENGTH = 2
        DICTIONARYDATA = 3
        DICTIONARYCOUNT = 4
        SECONDARY = 5
        ROWINDEX = 6
        BLOOMFILTER = 7
        BLOOMFILTERUTF8 = 8
        ENCRYPTEDINDEX = 9
        ENCRYPTEDDATA = 10
        STRIPESTATISTICS = 100
        FILESTATISTICS = 101
      end

      contract_of "proto2" do
        optional :kind, Stream::Kind, 1
        optional :column, :uint32, 2
        optional :length, :uint64, 3
      end
    end

    struct ColumnEncoding
      include ::Protobuf::Message
      enum Kind
        DIRECT = 0
        DICTIONARY = 1
        DIRECTV2 = 2
        DICTIONARYV2 = 3
      end

      contract_of "proto2" do
        optional :kind, ColumnEncoding::Kind, 1
        optional :dictionary_size, :uint32, 2
        optional :bloom_encoding, :uint32, 3
      end
    end

    struct StripeEncryptionVariant
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :streams, Stream, 1
        repeated :encoding, ColumnEncoding, 2
      end
    end

    struct StripeFooter
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :streams, Stream, 1
        repeated :columns, ColumnEncoding, 2
        optional :writer_timezone, :string, 3
        repeated :encryption, StripeEncryptionVariant, 4
      end
    end

    struct StringPair
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :key, :string, 1
        optional :value, :string, 2
      end
    end

    struct Type
      include ::Protobuf::Message
      enum Kind
        BOOLEAN = 0
        BYTE = 1
        SHORT = 2
        INT = 3
        LONG = 4
        FLOAT = 5
        DOUBLE = 6
        STRING = 7
        BINARY = 8
        TIMESTAMP = 9
        LIST = 10
        MAP = 11
        STRUCT = 12
        UNION = 13
        DECIMAL = 14
        DATE = 15
        VARCHAR = 16
        CHAR = 17
        TIMESTAMPINSTANT = 18
      end

      contract_of "proto2" do
        optional :kind, Type::Kind, 1
        repeated :subtypes, :uint32, 2, packed: true
        repeated :field_names, :string, 3
        optional :maximum_length, :uint32, 4
        optional :precision, :uint32, 5
        optional :scale, :uint32, 6
        repeated :attributes, StringPair, 7
      end
    end

    struct StripeInformation
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :offset, :uint64, 1
        optional :index_length, :uint64, 2
        optional :data_length, :uint64, 3
        optional :footer_length, :uint64, 4
        optional :number_of_rows, :uint64, 5
        optional :encrypt_stripe_id, :uint64, 6
        repeated :encrypted_local_keys, :bytes, 7
      end
    end

    struct UserMetadataItem
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :name, :string, 1
        optional :value, :bytes, 2
      end
    end

    struct StripeStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :col_stats, ColumnStatistics, 1
      end
    end

    struct Metadata
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :stripe_stats, StripeStatistics, 1
      end
    end

    struct ColumnarStripeStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :col_stats, ColumnStatistics, 1
      end
    end

    struct FileStatistics
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :column, ColumnStatistics, 1
      end
    end

    struct DataMask
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :name, :string, 1
        repeated :mask_parameters, :string, 2
        repeated :columns, :uint32, 3, packed: true
      end
    end

    struct EncryptionKey
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :key_name, :string, 1
        optional :key_version, :uint32, 2
        optional :algorithm, EncryptionAlgorithm, 3
      end
    end

    struct EncryptionVariant
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :root, :uint32, 1
        optional :key, :uint32, 2
        optional :encrypted_key, :bytes, 3
        repeated :stripe_statistics, Stream, 4
        optional :file_statistics, :bytes, 5
      end
    end

    struct Encryption
      include ::Protobuf::Message

      contract_of "proto2" do
        repeated :mask, DataMask, 1
        repeated :key, EncryptionKey, 2
        repeated :variants, EncryptionVariant, 3
        optional :key_provider, KeyProviderKind, 4
      end
    end

    struct Footer
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :header_length, :uint64, 1
        optional :content_length, :uint64, 2
        repeated :stripes, StripeInformation, 3
        repeated :types, Type, 4
        repeated :metadata, UserMetadataItem, 5
        optional :number_of_rows, :uint64, 6
        repeated :statistics, ColumnStatistics, 7
        optional :row_index_stride, :uint32, 8
        optional :writer, :uint32, 9
        optional :encryption, Encryption, 10
        optional :calendar, CalendarKind, 11
        optional :software_version, :string, 12
      end
    end

    struct PostScript
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :footer_length, :uint64, 1
        optional :compression, CompressionKind, 2
        optional :compression_block_size, :uint64, 3
        repeated :version, :uint32, 4, packed: true
        optional :metadata_length, :uint64, 5
        optional :writer_version, :uint32, 6
        optional :stripe_statistics_length, :uint64, 7
        optional :magic, :string, 8000
      end
    end

    struct FileTail
      include ::Protobuf::Message

      contract_of "proto2" do
        optional :postscript, PostScript, 1
        optional :footer, Footer, 2
        optional :file_length, :uint64, 3
        optional :postscript_length, :uint64, 4
      end
    end
    end
  end
