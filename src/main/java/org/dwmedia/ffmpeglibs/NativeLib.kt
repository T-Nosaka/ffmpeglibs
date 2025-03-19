package org.dwmedia.ffmpeglibs

class NativeLib {

    /*
     * AndroidCpuFamilyType型
     */
    enum class AndroidCpuFamilyType( val result : Int ) {
        UNKNOWN(0),
        ARM(1),
        X86(2),
        MIPS(3),
        ARM64(4),
        X86_64(5),
        MIPS64(6),
        RISCV64(7);

        companion object {
            @JvmStatic
            fun valueOf(typeId:Int) :AndroidCpuFamilyType {
                val filtered = entries.firstOrNull { it.result == typeId }
                return filtered ?: UNKNOWN
            }
        }
    }

    /*
     * AndroidCpuArmFeatureType型
     */
    enum class AndroidCpuArmFeatureType( val result : UInt ) {
        ARMv7        (1u shl 0),
        VFPv3        (1u shl 1),
        NEON         (1u shl 2),
        LDREX_STREX  (1u shl 3),
        VFPv2        (1u shl 4),
        VFP_D32      (1u shl 5),
        VFP_FP16     (1u shl 6),
        VFP_FMA      (1u shl 7),
        NEON_FMA     (1u shl 8),
        IDIV_ARM     (1u shl 9),
        IDIV_THUMB2  (1u shl 10),
        iWMMXt       (1u shl 11),
        AES          (1u shl 12),
        PMULL        (1u shl 13),
        SHA1         (1u shl 14),
        SHA2         (1u shl 15),
        CRC32        (1u shl 16)
    }

    /*
     * AndroidCpuArm64FeatureType型
     */
    enum class AndroidCpuArm64FeatureType( val result : UInt ) {
        FP        (1u shl 0),
        ASIMD     (1u shl 1),
        AES       (1u shl 2),
        PMULL     (1u shl 3),
        SHA1      (1u shl 4),
        SHA2      (1u shl 5),
        CRC32     (1u shl 6)
    }

    /*
     * AndroidCpuX86FeatureType型
     */
    enum class AndroidCpuX86FeatureType(val result: UInt) {
        SSSE3  (1u shl 0),
        POPCNT (1u shl 1),
        MOVBE  (1u shl 2),
        SSE4_1 (1u shl 3),
        SSE4_2 (1u shl 4),
        AES_NI (1u shl 5),
        AVX    (1u shl 6),
        RDRAND (1u shl 7),
        AVX2   (1u shl 8),
        SHA_NI (1u shl 9)
    }

    /*
     * AndroidCpuMIPSFeatureType型
     */
    enum class AndroidCpuMIPSFeatureType(val result: UInt) {
        R6    (1u shl 0),
        MSA   (1u shl 1)
    }

    /*
     * AVMediaType型
     */
    enum class AVMediaType( val result : Int ) {
        AVMEDIA_TYPE_UNKNOWN(-1),
        AVMEDIA_TYPE_VIDEO(0),
        AVMEDIA_TYPE_AUDIO(1),
        AVMEDIA_TYPE_DATA(2),
        AVMEDIA_TYPE_SUBTITLE(3),
        AVMEDIA_TYPE_ATTACHMENT(4),
        AVMEDIA_TYPE_NB(5);

        companion object {
            @JvmStatic
            fun valueOf(typeId:Int) :AVMediaType {
                val filtered = entries.firstOrNull { it.result == typeId }
                return filtered ?: AVMEDIA_TYPE_UNKNOWN
            }
        }
    }

    /*
     * 進捗情報
     */
    data class Report2(
        var total_size : Long,
        var last_time: Long,
        var nb_input_files: Int,
        var nb_output_files: Int,
        var nb_filtergraphs: Int,
        var nb_decoders: Int,
        var duration: ULong,
        var elapsed: ULong,
        var bitrate: Double,
        var speed: Double ) {

        /*
         * 出力情報
         */
        data class Ost(
            var vid : Int,
            var q : Float,
            var mediatype : AVMediaType,
            var frame_number : Long,
            var fps : Float,
            var outfilter : Boolean,
            var nb_frames_dup : Long,
            var nb_frames_drop : Long)

        /*
         * 出力リスト
         */
        var osts = ArrayList<Ost>()

        /*
         * 出力リスト追加
         */
        fun addOst( ost : Ost ) {
            osts.add(ost)
        }
    }

    /*
     * 進捗情報呼び出しInterface
     */
    interface ProgressInterface {
        fun onProgress( report : Report2 ) : Boolean
    }

    companion object {

        /*
         * CPU情報
         */
        @JvmStatic
        external fun CPUInfo( ) : String

        /*
         * 解析処理
         */
        @JvmStatic
        external fun Parse(jinputpath: String ) : String

        /*
         * 変換処理
         */
        @JvmStatic
        external fun Convert(fftoolsargs: Array<String>, reportcallif : ProgressInterface ) : Int

        // Used to load the 'ffmpeglibs' library on application startup.
        init {
            System.loadLibrary("ffmpeglibs")
        }
    }
}